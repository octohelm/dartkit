BUN = bun
BUNX = bunx --bun

dep:
	$(BUN) install

test:
	$(BUNX) turbo run test --force

fmt:
	$(BUNX) turbo run fmt --force

pub:
	$(BUNX) @morlay/bunpublish@0.1.6

clean:
	find . -name '.dart_tool' -type d -prune -print -exec rm -rf '{}' \;
	find . -name '.turbo' -type d -prune -print -exec rm -rf '{}' \;
	find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;