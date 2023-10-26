BUN = bun
BUNX = bunx --bun

dep:
	$(BUN) install

dep.update:
	$(BUNX) npm-check-updates --root -ws -ui

test:
	$(BUNX) turbo run test --force

fmt:
	$(BUNX) turbo run fmt --force

gen:
	$(BUNX) turbo run gen

pub:
	$(BUNX) @morlay/bunpublish@0.1.7

clean:
	find . -name '.dart_tool' -type d -prune -print -exec rm -rf '{}' \;
	find . -name '.turbo' -type d -prune -print -exec rm -rf '{}' \;
	find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;