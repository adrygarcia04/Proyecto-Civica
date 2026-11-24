{% macro carga_desde(column, source_system=none) -%}
(
    select coalesce(max(t.{{ column }}), '1900-01-01'::timestamp_ntz)
    from {{ this }} t
    {% if source_system is not none %}
    where t.source_system = '{{ source_system }}'
    {% endif %}
)
{%- endmacro %}