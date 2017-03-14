package io.astefanutti.metrics.aspectj.se;

import io.astefanutti.metrics.aspectj.AsyncTimed;
import io.astefanutti.metrics.aspectj.Metrics;

import java.util.concurrent.CompletableFuture;

/**
 */
@Metrics(registry = "asyncTimedRegistry")
public class SimpleAsyncTimed {
    @AsyncTimed
    public CompletableFuture<Integer> meteredMethod() throws InterruptedException {
        Thread.sleep(1000);
        return CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(3000);
            } catch (InterruptedException ignored){
            }

            return 10;
        });
    }
}
