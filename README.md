# Filefling

Simple command-line tool for uploading files to S3 with generated download links.

## Installation

```
gem install filefling
```

## Configuration

Configure Filefling using any of these methods (in order of precedence):

1. Command line options
2. Environment variables
3. Config file (~/.filefling.yml)

### AWS Credentials

Set up your AWS credentials using either:

Environment variables:
```
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_REGION="us-east-1"
```

Or AWS credentials file (~/.aws/credentials)

### Configuration Options

Config file (~/.filefling.yml):
```yaml
bucket: your-bucket-name
region: us-east-1
expires: 24
prefix: uploads/
```

Environment variables:
```
FILEFLING_BUCKET=your-bucket-name
FILEFLING_REGION=us-east-1
FILEFLING_EXPIRES=24
FILEFLING_PREFIX=uploads/
```

## Usage

Basic upload:
```
filefling upload path/to/file.txt
```

With options:
```
filefling upload path/to/file.txt --bucket custom-bucket --expires 48 --prefix temp/
```

### Options

--bucket BUCKET    S3 bucket name
--expires HOURS    Link expiration time in hours (default: 24)
--prefix PREFIX    Add prefix to uploaded filename
--region REGION    AWS region

## Example Output

```
Uploaded successfully!
Download link (expires in 24h): https://bucket.s3.amazonaws.com/random-filename.txt
```

## Requirements

- Ruby >= 3.0.0
- AWS credentials with S3 access
- S3 bucket with appropriate permissions

## Development

After checking out the repo:

1. Run `bin/setup` to install dependencies
2. Run `rake test` to run tests
3. Run `bin/console` for interactive prompt

## Contributing

Bug reports and pull requests welcome on GitHub at https://github.com/durableprogramming/filefling

## License

MIT License - see LICENSE.txt
