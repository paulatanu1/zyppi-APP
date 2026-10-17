#!/usr/bin/env bash
# One-time upload of the seed data's catalog images into the
# `catalog-images` Storage bucket, at the exact object paths
# supabase/seed.sql references (see that file's header comment).
#
# Prerequisites:
#   - Supabase CLI installed and this project linked (already true here:
#     supabase/.temp/project-ref)
#   - Authenticated: `supabase login`, or SUPABASE_ACCESS_TOKEN set
#
# Usage: ./scripts/upload_catalog_images.sh
set -euo pipefail

cd "$(dirname "$0")/.."

ASSETS_DIR="assets/images"
BUCKET="catalog-images"

# local_file:bucket_path pairs, derived from supabase/seed.sql
PAIRS=(
  "category.png:categories/category.png"
  "bread.png:categories/bread.png"
  "rice.png:categories/rice.png"
  "oil.png:categories/oil.png"
  "meat.png:categories/meat.png"
  "beverages.png:categories/beverages.png"
  "veg.png:products/veg.png"
  "apple.png:products/apple.png"
  "bread.png:products/bread.png"
  "rice.png:products/rice.png"
  "oil.png:products/oil.png"
  "meat.png:products/meat.png"
  "milk.png:products/milk.png"
  "item.png:products/item.png"
)

for pair in "${PAIRS[@]}"; do
  local_file="${pair%%:*}"
  object_path="${pair##*:}"
  src="$ASSETS_DIR/$local_file"
  dest="ss:///$BUCKET/$object_path"

  if [[ ! -f "$src" ]]; then
    echo "SKIP (missing local file): $src" >&2
    continue
  fi

  echo "Uploading $src -> $dest"
  supabase --experimental storage cp "$src" "$dest"
done

echo "Done. Verify with e.g.:"
echo "  curl -i https://dcgjsspymailbciqkhvq.supabase.co/storage/v1/object/public/$BUCKET/products/apple.png"
