#!/usr/bin/env bash
set -euxo pipefail

rm -rf asdf-plugins
git clone --depth 1 https://github.com/asdf-vm/asdf-plugins
rm -f src/shorthand_list.rs

num_plugins=$(find asdf-plugins/plugins/* | wc -l | tr -d ' ')
num_plugins=$((num_plugins + 1)) # +1 for node alias to nodejs

cat > src/shorthand_list.rs <<EOF
// This file is generated by scripts/update-shorthand-repo.sh
// Do not edit this file manually

pub const SHORTHAND_LIST: [(&str, &str); $num_plugins] = [
    // rtx custom aliases
    ("node", "https://github.com/asdf-vm/asdf-nodejs.git"),

    // asdf original aliases from https://github.com/asdf-vm/asdf-plugins
EOF
for file in asdf-plugins/plugins/*; do
    plugin=$(basename "$file")
    repository=$(cat "$file")
    repository="${repository/#repository = }"
    echo "    (\"$plugin\", \"$repository\")," >> src/shorthand_list.rs
done
cat >> src/shorthand_list.rs <<EOF
];
EOF
rm -rf asdf-plugins