SELECT 
      _airbyte_data['id']::Float64 as id
    , _airbyte_data['grouping'] as grouping
    , _airbyte_data['source'] as source
    , _airbyte_data['medium'] as medium
    , _airbyte_data['campaign'] as campaign
    , _airbyte_data['content'] as content
    , _airbyte_data['keyword'] as keyword
    , _airbyte_data['landing_page'] as landing_page
    , _airbyte_data['traffic_hash'] as traffic_hash
FROM s3('https://storage.yandexcloud.net/{{ env_var("S3_BUCKET_NAME") }}/mybi/general_traffic/*'
    , JSONEachRow
)
