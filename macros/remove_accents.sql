{% macro remove_accents(column_name) %}
    TRANSLATE(
        REPLACE(
            REPLACE(
                {{ column_name }},
                'ñ', 'gn'
            ),
            'Ñ', 'Gn'
        ),
        'áàäâÁÀÄÂéèëêÉÈËÊíìïîÍÌÏÎóòöôÓÒÖÔúùüûÚÙÜÛç',
        'aaaaAAAAeeeeEEEEiiiiIIIIooooOOOOuuuuUUUUc'
    )
{% endmacro %}