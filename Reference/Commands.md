# Commands

## Lint everything

```bash
cd /Users/cyrusbadde/projects/plugins/digital-cart
for f in $(find . -name "*.php" -not -path "./vendor/*"); do php -l "$f" > /dev/null || echo "FAIL $f"; done
```

## Which templates are still missing

See the Python snippet in [[../03 Build Status]].

## Which container modules are missing

```bash
cd /Users/cyrusbadde/projects/plugins/digital-cart
python3 -c "
import re, os
s = open('src/Plugin.php').read()
for m in re.findall(r'([A-Za-z\\\\\\\\]+)::class', s):
    p = 'src/' + m.replace('\\\\', '/') + '.php'
    if not os.path.isfile(p): print('MISSING', m)
"
```

Note: shell escaping of PHP namespace backslashes is a recurring trap. Prefer Python
heredocs over `grep`/`tr` pipelines for anything touching namespaces.

## Counts

```bash
find src -name '*.php' | wc -l          # 98
find templates -name '*.php' | wc -l    # 16
```
