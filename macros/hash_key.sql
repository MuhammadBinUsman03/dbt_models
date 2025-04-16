{# 
    Macro to generate a hash key from one or more columns
    This is used in data vault modeling to create unique identifiers for business entities
    
    Args:
        columns: A list of column names to be included in the hash key
        
    Returns:
        A SQL expression that generates an MD5 hash of the concatenated columns
#}

{% macro hash_key(columns) %}
    {% if columns is string %}
        {% set columns = [columns] %}
    {% endif %}
    
    {% set concatenated_columns = [] %}
    
    {% for column in columns %}
        {% set column_expression = "coalesce(cast(" ~ column ~ " as varchar), '')" %}
        {% do concatenated_columns.append(column_expression) %}
    {% endfor %}
    
    {% set concatenated_string = concatenated_columns | join(" || '|' || ") %}
    
    MD5({{ concatenated_string }})
    
{% endmacro %}
