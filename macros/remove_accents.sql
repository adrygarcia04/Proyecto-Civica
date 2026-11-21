{% macro remove_accents(column_name) %}
    TRANSLATE(
        REPLACE(
            REPLACE(
                {{ column_name }},
                'ñ', 'gn'
            ),
            'Ñ', 'GN'
        ),
        'áàäâÁÀÄÂéèëêÉÈËÊíìïîÍÌÏÎóòöôÓÒÖÔúùüûÚÙÜÛç',
        'aaaaAAAAeeeeEEEEiiiiIIIIooooOOOOuuuuUUUUc'
    )
{% endmacro %}