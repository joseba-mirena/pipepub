#!/bin/bash
# .github/lang/es-es.sh - Spanish (Spain) language pack

LANG_CODE="es-es"
LANG_NAME="Español (España)"

# General messages
MSG_WELCOME="Bienvenido a PipePub"
MSG_GOODBYE="¡Adiós!"

# Publishing messages
MSG_PUBLISH_START="Iniciando pipeline..."
MSG_PUBLISH_SUCCESS="¡Publicación completada exitosamente!"
MSG_PUBLISH_FAILURE="¡Error en la publicación!"
MSG_PUBLISH_CONFIRM="¿Continuar con la publicación? (s/N)"
MSG_PUBLISH_ABORTED="Cancelado."

# Service messages
MSG_SERVICE_PUBLISHING="Publicando en {service}"
MSG_SERVICE_SUCCESS="Publicado exitosamente en {service}"
MSG_SERVICE_FAILURE="Error al publicar en {service}"
MSG_SERVICE_MISSING_TOKEN="Falta el token para {service}"
MSG_SERVICE_MISSING_CONFIG="Falta la configuración para {service}"
MSG_SERVICE_PARTIAL_CONFIG="Configuración parcial para {service} (OAuth necesario)"

# Secret messages
MSG_SECRET_NO_MASTER="No se encontró clave maestra."
MSG_SECRET_MASTER_CREATED="Clave maestra creada."
MSG_SECRET_SAVED="{field} guardado"
MSG_SECRET_NOT_SAVED="{field} no guardado (revise el formato)"
MSG_SECRET_SKIPPED="Omitido (vacío)"
MSG_SECRET_REMOVED="Secretos de {service} eliminados"
MSG_SECRET_NO_SERVICES="No hay servicios configurados aún."
MSG_SECRET_ADD_INSTRUCTION="Ejecute: ./tools/pipepub.sh secrets add <service>"

# Confirmation messages
MSG_CONFIRM_REMOVE="¿Eliminar todos los secretos de '{service}'? (s/N)"
MSG_CONFIRM_CONTINUE="¿Continuar? (s/N)"

# Input prompts
MSG_PROMPT_CHOICE="Opción"
MSG_PROMPT_SELECT_SERVICE="Seleccione servicio"
MSG_PROMPT_PRESS_ENTER="Presione Enter para continuar..."
MSG_PROMPT_ENTER_SECRET="Ingrese {field}"

# Status messages
MSG_STATUS_CONFIGURED="configurado"
MSG_STATUS_PARTIAL="parcial"
MSG_STATUS_MISSING="no configurado"