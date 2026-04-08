#!/usr/bin/with-contenv bashio

NOMBRE=$(bashio::config 'nombre')
VPS_URL="http://168.231.93.65:5000/scanner"
DATA_DIR="/data"
DEPS_DIR="$DATA_DIR/deps"
SCANNER="$DATA_DIR/scanner_rpi.py"

bashio::log.info "========================================"
bashio::log.info " Scanner Obleas GNC — Nodo: $NOMBRE"
bashio::log.info "========================================"

# Instalar dependencias si no están
if [ ! -d "$DEPS_DIR/psycopg2" ]; then
    bashio::log.info "Instalando dependencias..."
    pip3 install --quiet --target "$DEPS_DIR" psycopg2-binary requests beautifulsoup4
    bashio::log.info "Dependencias instaladas."
fi

# Descargar última versión del scanner desde VPS
bashio::log.info "Descargando scanner desde servidor central..."
curl -sL "$VPS_URL/scanner_rpi.py" -o "$SCANNER.new" 2>/dev/null
if [ -s "$SCANNER.new" ]; then
    mv "$SCANNER.new" "$SCANNER"
    bashio::log.info "Scanner actualizado OK."
else
    bashio::log.warning "No se pudo descargar el scanner. Usando versión anterior si existe."
    rm -f "$SCANNER.new"
fi

if [ ! -f "$SCANNER" ]; then
    bashio::log.error "No hay scanner disponible. Abortando."
    exit 1
fi

cd "$DATA_DIR"
RONDA=1

bashio::log.info "Iniciando escaneo continuo..."

while true; do
    bashio::log.info "--- Ronda $RONDA: sentinel (150 obleas) ---"
    PYTHONPATH="$DEPS_DIR" python3 "$SCANNER" --node-id "${NOMBRE}_s" --count 150

    bashio::log.info "--- Ronda $RONDA: helper (300 obleas) ---"
    PYTHONPATH="$DEPS_DIR" python3 "$SCANNER" --node-id "$NOMBRE" --count 300

    bashio::log.info "Ronda $RONDA completada. Pausa 60s..."
    RONDA=$((RONDA+1))
    sleep 60
done
