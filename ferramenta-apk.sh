#!/usr/bin/env bash
set -e

APK_ORIG="Lithium Browser.apk"
PASTA_EDIT="lithium-descompilado"
APK_EDIT="Lithium-Browser-editado.apk"
APK_ASSINADO="Lithium-Browser-assinado.apk"
KEYSTORE="minha-chave.keystore"
ALIAS="lithium"

while true; do
  echo ""
  echo "=== FERRAMENTA DE EDIÇÃO DE APK ==="
  echo "1) Descompilar '$APK_ORIG'"
  echo "2) Recompilar '$PASTA_EDIT' -> '$APK_EDIT'"
  echo "3) Assinar '$APK_EDIT' -> '$APK_ASSINADO'"
  echo "4) Instalar/Atualizar '$APK_ASSINADO' via ADB (-r)"
  echo "5) Sair"
  read -rp "Escolha uma opção [1-5]: " op

  case "$op" in
    1)
      if [ ! -f "$APK_ORIG" ]; then
        echo "Erro: '$APK_ORIG' não encontrado na pasta atual."
      else
        rm -rf "$PASTA_EDIT"
        apktool d "$APK_ORIG" -o "$PASTA_EDIT"
        echo "Pronto! Edite os arquivos dentro de '$PASTA_EDIT'."
      fi
      ;;
    2)
      if [ ! -d "$PASTA_EDIT" ]; then
        echo "Erro: pasta '$PASTA_EDIT' não encontrada. Descompile primeiro (opção 1)."
      else
        apktool b "$PASTA_EDIT" -o "$APK_EDIT"
        echo "Pronto! Gerado '$APK_EDIT'."
      fi
      ;;
    3)
      if [ ! -f "$APK_EDIT" ]; then
        echo "Erro: '$APK_EDIT' não encontrado. Recompile primeiro (opção 2)."
      else
        if [ ! -f "$KEYSTORE" ]; then
          echo "Chave '$KEYSTORE' não encontrada. Criando agora..."
          keytool -genkeypair -v -keystore "$KEYSTORE" -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000
        fi
        apksigner sign --ks "$KEYSTORE" --ks-key-alias "$ALIAS" --out "$APK_ASSINADO" "$APK_EDIT"
        apksigner verify "$APK_ASSINADO"
        echo "Pronto! Assinado em '$APK_ASSINADO'."
      fi
      ;;
    4)
      if [ ! -f "$APK_ASSINADO" ]; then
        echo "Erro: '$APK_ASSINADO' não encontrado. Assine primeiro (opção 3)."
      else
        adb install -r "$APK_ASSINADO"
      fi
      ;;
    5)
      echo "Saindo..."
      exit 0
      ;;
    *)
      echo "Opção inválida."
      ;;
  esac
done
