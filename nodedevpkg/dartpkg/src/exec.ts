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

  void (async () => {
    for await (const chunk of proc.stdout) {
      Buffer.from(chunk).toString().trim().split(/\r\n?|\n/).forEach((l) => {
        logger.info(l);
      });
    }
  })();

  void (async () => {
    for await (const chunk of proc.stderr) {
      Buffer.from(chunk).toString().trim().split(/\r\n?|\n/).forEach((l) => {
        logger.error(l);
      });
    }
  })();

  return await proc.exited;
};