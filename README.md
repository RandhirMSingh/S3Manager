# S3Manager
````yml
uses: RandhirMSingh/S3Manager@main
   with:
     args: --acl public-read
   env:
    FILE:  File.txt
    AWS_REGION: 'us-east-1'
    S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
    S3_KEY: ${{ secrets.S3_KEY }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
 ````
