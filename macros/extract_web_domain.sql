{% macro extract_web_domain(column_name) %}
    regexp_replace(regexp_substr({{ column_name }},'^(https?://)?(www\\.)?([^/:?#]+)',1, 1, 'i', 3),'^www\\.','')
{% endmacro %}