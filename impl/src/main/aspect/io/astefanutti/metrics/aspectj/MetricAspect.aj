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
import com.codahale.metrics.MetricRegistry;
import com.codahale.metrics.Timer;
import com.codahale.metrics.annotation.ExceptionMetered;
import com.codahale.metrics.annotation.Gauge;
import com.codahale.metrics.annotation.Metered;
import com.codahale.metrics.annotation.Timed;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

final aspect MetricAspect extends AbstractMetricAspect {

    declare precedence: MetricStaticAspect, MetricAspect, *;

    declare parents : (@Metrics *) implements Profiled;

    final Map<String, AnnotatedMetric<com.codahale.metrics.Gauge>> Profiled.gauges = new ConcurrentHashMap<>();

    final Map<String, AnnotatedMetric<Meter>> Profiled.meters = new ConcurrentHashMap<>();

    final Map<String, AnnotatedMetric<Timer>> Profiled.timers = new ConcurrentHashMap<>();

    pointcut profiled(Profiled object) : execution((@Metrics Profiled+).new(..)) && this(object);

    after(final Profiled object) : profiled(object) {
        final MetricStrategy strategy = MetricStrategyFactory.newInstance(object);

        Class<?> clazz = object.getClass();
        do {
            // TODO: discover annotations declared on implemented interfaces
            for (final Method method : clazz.getDeclaredMethods()) {
                // Skip advising static methods
                if (Modifier.isStatic(method.getModifiers())) {
                    continue;
                }

                final Class<?> type = clazz;

                final Metrics annotation = type.getAnnotation(Metrics.class);

                final String registryName = annotation == null ? "metrics-registry" : annotation.registry();
                final DefaultNameResolver defaultNameResolver = SharedDefaultNameResolvers.get(registryName);

                AnnotatedMetric<Meter> exception = metricAnnotation(method, ExceptionMetered.class, (name, absolute) -> {
                    String finalName = name.isEmpty() ? defaultNameResolver.resolveMethod(method) + '.' + ExceptionMetered.DEFAULT_NAME_SUFFIX : strategy.resolveMetricName(name);
                    MetricRegistry registry = strategy.resolveMetricRegistry(registryName);
                    return registry.meter(absolute ? finalName : MetricRegistry.name(defaultNameResolver.resolveClass(type), finalName));
                });
                if (exception.isPresent()) {
                    object.meters.put(method.toString(), exception);
                }

                AnnotatedMetric<com.codahale.metrics.Gauge> gauge = metricAnnotation(method, Gauge.class, (name, absolute) -> {
                    String finalName = name.isEmpty() ? defaultNameResolver.resolveMethod(method) : strategy.resolveMetricName(name);
                    MetricRegistry registry = strategy.resolveMetricRegistry(registryName);

                    final String gaugeName = absolute ? finalName : MetricRegistry.name(defaultNameResolver.resolveClass(type), finalName);
                    try {
                        // possible race here ¯\_(ツ)_/¯
                        registry.remove(gaugeName);
                        registry.register(gaugeName, new ForwardingGauge(method, object));
                    } catch (IllegalArgumentException ignored) {
                    }
                    return registry.getGauges().get(gaugeName);
                });
                if (gauge.isPresent()) {
                    object.gauges.put(method.toString(), gauge);
                }

                AnnotatedMetric<Meter> meter = metricAnnotation(method, Metered.class, (name, absolute) -> {
                    String finalName = name.isEmpty() ? defaultNameResolver.resolveMethod(method) + ".meter" : strategy.resolveMetricName(name);
                    MetricRegistry registry = strategy.resolveMetricRegistry(registryName);
                    return registry.meter(absolute ? finalName : MetricRegistry.name(defaultNameResolver.resolveClass(type), finalName));
                });
                if (meter.isPresent()) {
                    object.meters.put(method.toString(), meter);
                }

                AnnotatedMetric<Timer> timer = metricAnnotation(method, Timed.class, (name, absolute) -> {
                    String finalName = name.isEmpty() ? defaultNameResolver.resolveMethod(method) + ".timer" : strategy.resolveMetricName(name);
                    MetricRegistry registry = strategy.resolveMetricRegistry(registryName);
                    return registry.timer(absolute ? finalName : MetricRegistry.name(defaultNameResolver.resolveClass(type), finalName));
                });
                if (timer.isPresent()) {
                    object.timers.put(method.toString(), timer);
                }

                AnnotatedMetric<Timer> asyncTimer = metricAnnotation(method, AsyncTimed.class, (name, absolute) -> {
                    String finalName = name.isEmpty() ? defaultNameResolver.resolveMethod(method) + ".asyncTimer" : strategy.resolveMetricName(name);
                    MetricRegistry registry = strategy.resolveMetricRegistry(registryName);
                    return registry.timer(absolute ? finalName : MetricRegistry.name(defaultNameResolver.resolveClass(type), finalName));
                });
                if (asyncTimer.isPresent()) {
                    object.timers.put(method.toString(), asyncTimer);
                }

                AnnotatedMetric<Meter> asyncException = metricAnnotation(method, AsyncExceptionMetered.class, (name, absolute) -> {
                    String finalName = name.isEmpty() ? defaultNameResolver.resolveMethod(method) + '.' + AsyncExceptionMetered.DEFAULT_NAME_SUFFIX : strategy.resolveMetricName(name);
                    MetricRegistry registry = strategy.resolveMetricRegistry(registryName);
                    return registry.meter(absolute ? finalName : MetricRegistry.name(defaultNameResolver.resolveClass(type), finalName));
                });
                if (asyncException.isPresent()) {
                    object.meters.put(method.toString(), asyncException);
                }
            }
            clazz = clazz.getSuperclass();
        } while (!Object.class.equals(clazz));
    }
}
