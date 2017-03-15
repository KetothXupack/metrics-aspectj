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

import com.codahale.metrics.Meter;
import io.astefanutti.metrics.aspectj.AsyncExceptionMetered;
import org.aspectj.lang.reflect.MethodSignature;

import java.util.concurrent.CompletableFuture;

final aspect AsyncExceptionMeteredAspect {

    pointcut asyncExceptionMetered(Profiled object) : execution(@AsyncExceptionMetered !static CompletableFuture (@Metrics Profiled+).*(..)) && this(object);

    Object around(Profiled object) : asyncExceptionMetered(object) {
        String methodSignature = ((MethodSignature) thisJoinPointStaticPart.getSignature()).getMethod().toString();
        AnnotatedMetric<Meter> metric = object.meters.get(methodSignature);

        final CompletableFuture result = (CompletableFuture) proceed(object);
        result.whenComplete((o, throwable) -> {
            if (metric.getAnnotation(AsyncExceptionMetered.class).cause().isInstance(throwable)) {
                metric.getMetric().mark();
            }
        });
        return result;
    }
}
