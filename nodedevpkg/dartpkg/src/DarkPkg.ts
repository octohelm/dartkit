import fs from "fs";
import { dump, load } from "js-yaml";
import { load as loadXML } from "cheerio";
import { manifest, type AbbreviatedManifest, type ManifestResult } from "pacote";
import { dirname, join, relative } from "path";
import { exec } from "./exec.ts";
import { createLogger } from "./logger.ts";

export class DarkPkg {
  static CONFIG_FILE_PUBSPEC = "./pubspec.yaml";
  static CONFIG_FILE_PUBSPEC_OVERRIDES = "./pubspec_overrides.yaml";

  static async load(root: string) {
    return new DarkPkg(
      await manifest(root) as Manifest,
      await pubspec(root) as PubSpec
    );
  }

  static isDarkPkg(name: string) {
    return name.includes("/dart-");
  }

  constructor(
    public manifest: Manifest,
    public pubspec: PubSpec
  ) {

  }

  static normalizePubSpecName = (name: string): string => {
    for (const prefix of ["/dart-"]) {
      if (name.includes(prefix)) {
        const parts = name.split(prefix);
        return parts[parts.length - 1]!;
      }
    }
    return name;
  };

  get dartCmd() {
    if (this.pubspec.dependencies?.["flutter"]) {
      return "flutter";
    }
    return "dart";
  }

  async postInstall() {
    const pubSpec = {
      name: DarkPkg.normalizePubSpecName(this.manifest.name),
      version: this.manifest.version,
      environment: {
        sdk: this.manifest.engines?.["dart"] ?? ">=3.2.0 <4.0.0"
      },
      dependencies: this.pubspec.dependencies ?? {},
      dev_dependencies: this.pubspec.dev_dependencies ?? {},
      ...(() => {
        const {
          name,
          version,
          environment,
          dependencies,
          dev_dependencies,
          ...others
        } = this.pubspec;

        return others;
      })()
    };

    const dependencyOverrides = {} as Record<string, { path: string }>;

    const patch = async (pkgName: string, isDev: boolean) => {
      const index = await import.meta.resolve(pkgName, this.manifest._resolved);
      const resolvedDarkPkg = await DarkPkg.load(dirname(index));
      const pubSpecName = DarkPkg.normalizePubSpecName(resolvedDarkPkg.manifest.name);

      if (dependencyOverrides[pubSpecName]) {
        return;
      }

      (isDev ? pubSpec.dev_dependencies : pubSpec.dependencies)[pubSpecName] = `^${resolvedDarkPkg.manifest.version}`;

      dependencyOverrides[pubSpecName] = {
        path: relative(this.manifest._resolved, resolvedDarkPkg.manifest._resolved)
      };

      await resolvedDarkPkg.eachDarkPkgDep(patch);
    };


    await this.eachDarkPkgDep(patch);

    await writeYAML(join(this.manifest._resolved, DarkPkg.CONFIG_FILE_PUBSPEC), {
      ...pubSpec,
      dependencies: normalizeVersions(pubSpec.dependencies),
      dev_dependencies: normalizeVersions(pubSpec.dev_dependencies)
    });

    if (Object.keys(dependencyOverrides).length > 0) {
      await writeYAML(join(this.manifest._resolved, DarkPkg.CONFIG_FILE_PUBSPEC_OVERRIDES), {
        dependency_overrides: dependencyOverrides
      });
    }

    // dev mode
    if (!this.manifest._resolved.includes("node_modules")) {
      await this.registerIdeaModule();

      await exec([this.dartCmd, "pub", "get"], {
        name: "pubget",
        cwd: this.manifest._resolved,
        logger: createLogger(this.manifest.name)
      });
    }
  }

  async eachDarkPkgDep(patch: (name: string, isDev: boolean) => Promise<void>) {
    for (const pkgName in (this.manifest.dependencies ?? {})) {
      if (DarkPkg.isDarkPkg(pkgName)) {
        await patch(pkgName, false);
      }
    }

    for (const pkgName in (this.manifest.devDependencies ?? {})) {
      if (DarkPkg.isDarkPkg(pkgName)) {
        await patch(pkgName, true);
      }
    }
  }

  async registerIdeaModule() {
    const imlFile = join(this.manifest._resolved, `${this.manifest.name.replace("/", "__")}.iml`);

    await writeFile(imlFile, this.iml);

    const projectRoot = await resolveProjectRoot(this.manifest._resolved);

    try {
      const modulesXML = join(projectRoot, ".idea/modules.xml");
      await fs.promises.access(modulesXML);

      const $ = loadXML(
        String(await fs.promises.readFile(modulesXML)),
        {
          xml: true,
          xmlMode: true
        }
      );
      const rel = relative(projectRoot, imlFile);

      $(`project > component > modules > module` as any).each((i, el) => {
        if ($(el).attr("fileurl")?.endsWith(rel)) {
          $(el).remove();
        }
      });

      $(`project > component > modules` as any)
        .append(`<module fileurl="file://&#x24;PROJECT_DIR&#x24;/${rel}" filepath="&#x24;PROJECT_DIR&#x24;/${rel}" />
` as any
        );

      await fs.promises.writeFile(modulesXML, $.xml());
    } catch (err) {
      console.log(err);
    }
  }

  get iml() {
    return `
<?xml version="1.0" encoding="UTF-8"?>
<module type="WEB_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$" isTestSource="false" />
      <excludeFolder url="file://$MODULE_DIR$/build" />
      <excludeFolder url="file://$MODULE_DIR$/.turbo" />
    </content>
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Dart SDK" level="project" />
    <orderEntry type="library" name="Dart Packages" level="project" />
  </component>
</module>    
`.trim();
  }
}

export type Manifest = AbbreviatedManifest & ManifestResult

export type PubSpec = {
  name: string
  version: string
  environment: Record<string, any>
  dependencies?: Record<string, any>;
  dev_dependencies?: Record<string, any>;
  [x: string]: any,
}

async function pubspec(cwd: string) {
  return load(String(await fs.promises.readFile(join(cwd, DarkPkg.CONFIG_FILE_PUBSPEC)))) as PubSpec;
}

async function writeYAML(filename: string, data: any) {
  return await writeFile(filename, dump(data));
}

async function writeFile(filename: string, data: string) {
  return await fs.promises.writeFile(filename, data);
}

async function resolveProjectRoot(root: string) {
  if (root == "/" || root == "") {
    throw new Error("must run project with git");
  }

  try {
    await fs.promises.access(join(root, ".git"));
    return root;
  } catch (e) {
    return resolveProjectRoot(join(root, ".."));
  }
}

function normalizeVersions(versions: Record<string, string>): Record<string, any> {
  const resolved: Record<string, any> = {};

  for (const pkgName in versions) {
    const version = versions[pkgName] as unknown;

    if (typeof version == "string" && version.includes(":")) {
      // sdk:flutter
      const [k, v] = version.split(":", 2);
      resolved[pkgName] = { [k]: v };
      continue;
    }

    resolved[pkgName] = version;
  }

  return resolved;
}

