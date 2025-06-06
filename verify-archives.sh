#!/bin/bash

SATIS_OUTPUT_DIR="public"

echo "🔍 Removendo campos 'shasum' dos metadados Satis em $SATIS_OUTPUT_DIR..."

# Verifica se o jq está instalado
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq não está instalado. Instale com: sudo apt install jq"
  exit 1
fi

# Remove 'shasum' de todos os arquivos JSON do diretório
find "$SATIS_OUTPUT_DIR" -type f -name "*.json" | while read -r jsonFile; do
  echo "🧹 Limpando: $jsonFile"
  jq 'walk(
    if type == "object" and has("dist") then .dist |= del(.shasum) else . end
  )' "$jsonFile" > "${jsonFile}.tmp" && mv "${jsonFile}.tmp" "$jsonFile"
done

echo "✅ Todos os campos 'shasum' foram removidos com sucesso."
# set -e

# PKG_JSON="public/packages.json"
# DIST_DIR="public/dist"

# echo "🔍 Verificando integridade dos pacotes ZIP..."

# errors=0

# # Verifica se o arquivo existe
# if [ ! -f "$PKG_JSON" ]; then
#   echo "❌ Arquivo $PKG_JSON não encontrado."
#   exit 1
# fi

# # Percorre todos os pacotes no packages.json
# jq -e -r '.packages | keys[]' "$PKG_JSON" | while read -r package; do
#   versions=$(jq -r --arg pkg "$package" '.packages[$pkg] | keys[]' "$PKG_JSON")
#   echo "📦 Pacote: $package"

#   for version in $versions; do
#     # Extrai dados do pacote
#     zip_url=$(jq -r --arg pkg "$package" --arg ver "$version" '.packages[$pkg][$ver].dist.url' "$PKG_JSON")
#     expected_shasum=$(jq -r --arg pkg "$package" --arg ver "$version" '.packages[$pkg][$ver].dist.shasum' "$PKG_JSON")

#     zip_file="${zip_url#http://localhost:8080/}"  # remove a parte do host
#     full_path="public/$zip_file"

#     echo "  ↪ Arquivo: $full_path"
#     if [ ! -f "$full_path" ]; then
#       echo "  ❌ Arquivo ausente: $full_path"
#       ((errors++))
#       continue
#     fi

#     real_shasum=$(shasum -a 256 "$full_path" | awk '{print $1}')
    
#     if [ "$real_shasum" != "$expected_shasum" ]; then
#       echo "  ❌ SHA mismatch para $package@$version"
#       echo "     Esperado: $expected_shasum"
#       echo "     Obtido  : $real_shasum"
#       ((errors++))
#     else
#       echo "  ✅ OK: $package@$version"
#     fi
#   done
# done

# echo

# if [ "$errors" -gt 0 ]; then
#   echo "⚠️  Validação concluída com $errors erro(s)."
#   exit 1
# else
#   echo "🎉 Todos os pacotes estão válidos!"
# fi
