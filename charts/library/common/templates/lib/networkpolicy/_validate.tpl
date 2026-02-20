{{/*
Validate networkPolicy values
*/}}
{{- define "bjw-s.common.lib.networkpolicy.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $networkpolicyObject := .object -}}

  {{- if and (not (hasKey $networkpolicyObject "podSelector")) (empty (get $networkpolicyObject "controller")) -}}
    {{- fail (printf "controller reference or podSelector is required for NetworkPolicy. (NetworkPolicy %s)" $networkpolicyObject.identifier) -}}
  {{- end -}}

  {{- $allowedTypes := list "kubernetes" "cilium" -}}
  {{- if and $networkpolicyObject.type (not (mustHas $networkpolicyObject.type $allowedTypes)) -}}
    {{- fail (
      printf "Not a valid type for NetworkPolicy. Allowed values are [%s]. (NetworkPolicy %s, value %s)"
      (join ", " $allowedTypes)
      $networkpolicyObject.identifier
      $networkpolicyObject.type
    ) -}}
  {{- end -}}


  {{- /* Only validate PolicyTypes on kubernetes networkpolicies */ -}}
  {{- if or (not $networkpolicyObject.type) (eq $networkpolicyObject.type "kubernetes") -}}
    {{- if empty (get $networkpolicyObject "policyTypes") -}}
      {{- fail (printf "policyTypes is required for NetworkPolicy. (NetworkPolicy %s)" $networkpolicyObject.identifier) -}}
    {{- end -}}

    {{- $allowedpolicyTypes := list "Ingress" "Egress" -}}
    {{- range $networkpolicyObject.policyTypes -}}
      {{- if not (has . $allowedpolicyTypes) -}}
        {{- fail (printf "Not a valid policyType for NetworkPolicy. (NetworkPolicy %s, value %s)" $networkpolicyObject.identifier .) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
