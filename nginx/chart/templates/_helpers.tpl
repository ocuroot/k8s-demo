{{/*
Labels for the chart's resources
*/}}
{{- define "ocuroot-nginx.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Annotations for the chart's service
*/}}
{{- define "ocuroot-nginx.annotations" -}}
{{- if .Values.loadBalancerId }}
kubernetes.digitalocean.com/load-balancer-id: {{ .Values.loadBalancerId }}
{{- end }}
{{- end -}}
