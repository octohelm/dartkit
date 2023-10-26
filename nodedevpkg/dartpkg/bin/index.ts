#!/usr/bin/env bun

import { Command } from "commander";
import { DarkPkg } from "../src";

const program = new Command();

program
  .command("postinstall")
  .description("convert to pubspec")
  .action(async () => {
    const dpkg = await DarkPkg.load(process.cwd());
    await dpkg.postInstall();
  });

program.parse(process.argv);
