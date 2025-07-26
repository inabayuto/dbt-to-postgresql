FROM python:3.12

# ワーキングディレクトリを設定
WORKDIR /dbt

# pythonのライブラリをインストール
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# 設定ファイルのコピー
COPY profiles.yml /tmp/profiles.yml

ENTRYPOINT [ "/bin/sh", "-c" ]

# プロジェクトの作成
CMD ["mkdir -p ~/.dbt && \
    if [ ! -f ~/.dbt/profiles.yml ]; then mv /tmp/profiles.yml ~/.dbt/profiles.yml; fi && \
    if [ ! -d /dbt/dbt_dev ]; then dbt init dbt_dev --profile dbt_dev; fi && \
    if [ ! -f /dbt/dbt_project.yml ]; then cp /dbt/dbt_dev/dbt_project.yml /dbt/; fi && \
    tail -f /dev/null"]