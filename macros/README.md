# DBT Macros

This directory contains macros used throughout the dbt project.

## Available Macros

### hash_key

The `hash_key` macro is used to generate a hash key from one or more columns. This is commonly used in data vault modeling to create unique identifiers for business entities.

#### Usage

```sql
{{ hash_key(['column1', 'column2']) }} as hash_key
```

#### Parameters

- `columns`: A list of column names to be included in the hash key. Can also be a single string for a single column.

#### Returns

A SQL expression that generates an MD5 hash of the concatenated columns, with a pipe (`|`) separator between values.

#### Example

```sql
select 
    {{ hash_key(['business_key']) }} as hash_key,
    business_key,
    load_date,
    record_source
from source_data
```

This will generate a SQL expression like:

```sql
MD5(coalesce(cast(business_key as varchar), ''))
```

For multiple columns:

```sql
{{ hash_key(['customer_id', 'order_id']) }} as hash_key
```

Will generate:

```sql
MD5(coalesce(cast(customer_id as varchar), '') || '|' || coalesce(cast(order_id as varchar), ''))
```
