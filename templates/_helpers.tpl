{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ines.name" -}}
{{- printf "%s-%s" "ines" (default .Chart.Name .Values.ines.nameOverride | trunc 58 | trimSuffix "-") -}}
{{- end -}}