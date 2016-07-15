#!/bin/bash

# このスクリプトが存在するディレクトリ
script_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
# デプロイ対象のローカルリポジトリ
repo_name="samplerepo"
repo_dir="${script_dir}/app_git/${repo_name}"
# .gitディレクトリの場所
git_dir="${repo_dir}/.git/"

HOSTS="127.0.0.1"
DEPLOY_USER=app
DATE=`date +%Y%m%d%H%M%S`

echo "script_dir: ${script_dir}"
echo "repo_dir: ${repo_dir}"
echo "git_dir: ${git_dir}"

# ローカルリポジトリの状態を最新にする
/bin/su - -c "cd ${repo_dir} && git --git-dir=${git_dir} checkout master" $DEPLOY_USER
/bin/su - -c "cd ${repo_dir} && git --git-dir=${git_dir} reset --hard" $DEPLOY_USER
/bin/su - -c "cd ${repo_dir} && git --git-dir=${git_dir} pull" $DEPLOY_USER

for HOST in $HOSTS; do
    # ファイルを転送する
    rsync -auv --exclude ".git/" --rsync-path /usr/bin/rsync -e "ssh -T -i /root/.ssh/id_rsa" ./app_git/${repo_name}/project/build/deploy/htdocs/html/ $HOST:/var/www/html/ > app/logs/web1_rsync_apache$DATE.log
    rsync -auv --exclude ".git/" --rsync-path /usr/bin/rsync -e "ssh -T -i /root/.ssh/id_rsa" ./app_git/${repo_name}/project/build/deploy/contextapp/ $DEPLOY_USER@$HOST:/opt/tomcat/webapps/contextapp/ > app/logs/web1_rsync_tomcat$DATE.log

    echo -n “Are you sure to restart tomcat? [yes/no]”
    read answer
    if [ "$answer" = "yes" ]
    then
        # サーバでシェルを実行する
        ssh -t -t $HOST "/usr/local/etc/init.d/tomcat restart"
    else
        echo "tomcat doesn't be restarted"
    fi
done;
echo "depolyment has been finished!!"
