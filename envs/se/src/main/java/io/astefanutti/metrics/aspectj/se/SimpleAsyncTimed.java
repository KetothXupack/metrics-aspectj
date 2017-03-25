/**
 * Copyright © 2013 Antonin Stefanutti (antonin.stefanutti@gmail.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.astefanutti.metrics.aspectj.se;

import io.astefanutti.metrics.aspectj.AsyncExceptionMetered;
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

    @AsyncExceptionMetered
    public CompletableFuture<Integer> exceptionMethod() throws InterruptedException {
        return CompletableFuture.supplyAsync(() -> {
            throw new IllegalStateException();
        });
    }
}
