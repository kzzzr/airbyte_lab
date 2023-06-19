SELECT 
      _airbyte_data['id']::Float64 as id
    , _airbyte_data['domain'] as domain
    , _airbyte_data['description'] as description  
FROM s3('https://storage.yandexcloud.net/{{ env_var("S3_BUCKET_NAME") }}/mybi/general_sites/*'
    , JSONEachRow
)
