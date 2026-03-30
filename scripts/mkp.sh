#!/usr/bin/env bash

# -------------------------------
# Deterministic Password Generator
# -------------------------------
# Generates a deterministic password from a seed phrase + optional pepper.
# The pepper is read from the MKP_PEPPER environment variable.
# Set it in your shell profile (e.g. ~/.bashrc):
#   export MKP_PEPPER="your-secret-pepper"

# Configuración
LENGTH=16
CHARS_UPPER="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
CHARS_LOWER="abcdefghijklmnopqrstuvwxyz"
CHARS_DIGITS="0123456789"
CHARS_SYMBOLS="!@#$%^&*()-_=+[]{}<>?"
CHARS="$CHARS_UPPER$CHARS_LOWER$CHARS_DIGITS$CHARS_SYMBOLS"

if [ -z "${MKP_PEPPER:-}" ]; then
	echo "Warning: MKP_PEPPER not set. Set it for stronger passwords." >&2
fi

# Leer semilla sin mostrar
read -rs -p "Enter seed: " SEED
echo
SEED="$SEED${MKP_PEPPER:-}"

# SHA-256 hash (Linux/macOS)
if command -v sha256sum >/dev/null 2>&1; then
	HASH=$(printf "%s" "$SEED" | sha256sum | awk '{print $1}')
else
	HASH=$(printf "%s" "$SEED" | shasum -a 256 | awk '{print $1}')
fi

# Generar password
PASS=""
i=0
while [ ${#PASS} -lt $LENGTH ]; do
	HEX_BYTE=${HASH:$((i * 2)):2}
	DEC=$((16#$HEX_BYTE))
	CHAR_INDEX=$((DEC % ${#CHARS}))
	PASS="$PASS${CHARS:$CHAR_INDEX:1}"
	i=$((i + 1))
	[ $i -ge $((${#HASH} / 2)) ] && i=0
done

echo "Generated password: $PASS"
