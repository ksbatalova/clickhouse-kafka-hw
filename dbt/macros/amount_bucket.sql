{# Сегментация суммы транзакции. Пороги можно переопределить аргументами. #}
{% macro amount_bucket(column_name, small=50, medium=200, large=1000) %}
    case
        when {{ column_name }} < {{ small }} then 'small'
        when {{ column_name }} < {{ medium }} then 'medium'
        when {{ column_name }} < {{ large }} then 'large'
        else 'very_large'
    end
{% endmacro %}
