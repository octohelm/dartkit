import type { Logger } from "./logger.ts";

export const exec = async (cmd: string[], { cwd, logger, name }: {
  cwd: string,
  logger: Logger,
  name: string
}): Promise<number> => {
  logger = logger.withName(name);

  const proc = Bun.spawn({
    cmd: cmd,
    cwd: cwd,
    stdout: "pipe",
    stderr: "pipe",
    env: {
      ...process.env
    }
  });

  proc.stdout.pipeTo(new WritableStream({
    write(chunk) {
      logger.info(new TextDecoder().decode(chunk).trim());
    }
  }));

  proc.stderr.pipeTo(new WritableStream({
    write(chunk) {
      logger.error(new TextDecoder().decode(chunk).trim());
    }
  }));

  return await proc.exited;
};