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
package io.astefanutti.metrics.aspectj;

import com.codahale.metrics.Timer;
import com.codahale.metrics.Timer.Context;
import io.astefanutti.metrics.aspectj.AsyncTimed;
import org.aspectj.lang.reflect.MethodSignature;

import java.util.concurrent.CompletableFuture;

final aspect AsyncTimedAspect {

    pointcut asyncTimed(Profiled object) : execution(@AsyncTimed !static * (@Metrics Profiled+).*(..)) && this(object);

    Object around(Profiled object) : asyncTimed(object) {
        String methodSignature = ((MethodSignature) thisJoinPointStaticPart.getSignature()).getMethod().toString();
        Timer timer = object.asyncTimers.get(methodSignature).getMetric();

        Context context = timer.time();
        final CompletableFuture result = (CompletableFuture) proceed(object);
        result.whenComplete((o, throwable) -> context.close());
        return result;
    }
}
