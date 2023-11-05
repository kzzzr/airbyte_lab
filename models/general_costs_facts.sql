SELECT 
      _airbyte_data['account_id'] as account_id
    , _airbyte_data['dates_id'] as dates_id
    , _airbyte_data['sites_id'] as sites_id
    , _airbyte_data['traffic_id'] as traffic_id
    , _airbyte_data['impressions'] as impressions
    , _airbyte_data['clicks'] as clicks
    , _airbyte_data['cost'] as cost
    , _airbyte_data['vat_included'] as vat_included    
FROM s3('https://storage.yandexcloud.net/{{ env_var("S3_BUCKET_NAME") }}/mybi/general_costs_facts/*'
    , JSONEachRow
)
