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

# Función para descargar la última versión del scanner
actualizar_scanner() {
    curl -sL --connect-timeout 15 "$VPS_URL/scanner_rpi.py" -o "$SCANNER.new" 2>/dev/null
    if [ -s "$SCANNER.new" ] && python3 -c "import ast; ast.parse(open('$SCANNER.new').read())" 2>/dev/null; then
        mv "$SCANNER.new" "$SCANNER"
        bashio::log.info "Scanner actualizado OK."
    else
        rm -f "$SCANNER.new"
        bashio::log.warning "No se pudo descargar el scanner. Usando versión anterior."
    fi
}

# Descarga inicial
actualizar_scanner

if [ ! -f "$SCANNER" ]; then
    bashio::log.error "No hay scanner disponible. Reintentando en 60s..."
    sleep 60
    actualizar_scanner
    [ ! -f "$SCANNER" ] && exit 1
fi

cd "$DATA_DIR"
RONDA=1

bashio::log.info "Iniciando escaneo continuo..."

while true; do
    # Actualizar scanner cada 10 rondas
    if [ $((RONDA % 10)) -eq 0 ]; then
        bashio::log.info "Verificando actualización del scanner..."
        actualizar_scanner
    fi

    bashio::log.info "--- Ronda $RONDA: helper (300 obleas) ---"
    PYTHONPATH="$DEPS_DIR" python3 "$SCANNER" --node-id "$NOMBRE" --count 300 || \
        bashio::log.warning "Helper terminó con error. Continuando..."

    bashio::log.info "--- Ronda $RONDA: sentinel (150 obleas) ---"
    PYTHONPATH="$DEPS_DIR" python3 "$SCANNER" --node-id "${NOMBRE}_sentinel" --count 150 || \
        bashio::log.warning "Sentinel terminó con error. Continuando..."

    bashio::log.info "Ronda $RONDA completada. Pausa 30s..."
    RONDA=$((RONDA+1))
    sleep 30
done
