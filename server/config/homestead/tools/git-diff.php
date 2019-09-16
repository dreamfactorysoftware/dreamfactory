<?php

$home = dirname(__FILE__);
$repos = new DirectoryIterator($home);
foreach ($repos as $repo) {
    if (! $repo->isDot() && $repo->isDir()) {
        $repoSrc = $repo->getRealPath();
        echo 'Checking '.basename($repoSrc)."\n";
        chdir($repoSrc);
        exec('git diff master..develop --name-status', $output);
        foreach ($output as $o) {
            echo $o."\n";
        }
        $output = null;
        echo "##############################################\n\n";
    }
}
chdir($home);
