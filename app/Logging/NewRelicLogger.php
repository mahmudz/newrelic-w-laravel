<?php
namespace App\Logging;

use Auth;
use Monolog\Logger;
use Illuminate\Http\Request;
use Monolog\Handler\BufferHandler;
use NewRelic\Monolog\Enricher\Handler;
use NewRelic\Monolog\Enricher\Processor;

class NewRelicLogger {
    protected $request;

    public function __construct(Request $request = null)
    {
        $this->request = $request;
    }

    public function __invoke(array $config)
    {
        $log = new Logger('newrelic');
        $log->pushProcessor(new Processor);
        $handler = new Handler;

        $log->pushHandler(new BufferHandler($handler));

        foreach ($log->getHandlers() as $handler) {
            $handler->pushProcessor([$this, 'includeMetaData']);
        }

        return $log;
    }

    public function includeMetaData(array $record): array
    {
        // set the service or app name to the record
        $record['service'] = 'Laravel-App-Name';

        // set the hostname to record so we know host this was created on
        $record['hostname'] = gethostname();

        // check to see if we have a request
        if($this->request){

            $record['extra'] += [
                'ip' => $this->request->getClientIp(),
            ];

            // get the authenticated user
            $user = Auth::user();

            // add the user information
            if($user){
                $record['user'] = [
                    'id' => $user->id ?? null,
                    'email' => $user->email ?? 'guest',
                ];
            }
        }
        return $record;
    }
}
