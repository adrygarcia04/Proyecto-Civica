{% macro remove_accents(column_name) %}
    translate(
        replace(
            replace(
                {{ column_name }},
                'ñ', 'gn'
            ),
            'Ñ', 'GN'
        ),
        'áàäâÁÀÄÂéèëêÉÈËÊíìïîÍÌÏÎóòöôÓÒÖÔúùüûÚÙÜÛç',
        'aaaaAAAAeeeeEEEEiiiiIIIIooooOOOOuuuuUUUUc'
    )
{% endmacro %}