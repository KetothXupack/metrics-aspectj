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

import com.codahale.metrics.MetricRegistry;
import com.codahale.metrics.SharedMetricRegistries;
import io.astefanutti.metrics.aspectj.se.util.MetricsUtil;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.concurrent.TimeUnit;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 */
public class AsyncMeteredTest {
    private SimpleAsyncTimed instance;

    @Before
    public void createTimedInstance() {
        instance = new SimpleAsyncTimed();
    }

    @After
    public void clearSharedMetricRegistries() {
        SharedMetricRegistries.clear();
    }

    private static final String REGISTRY_NAME = "asyncTimedRegistry";

    @Test
    public void correctlyMeterAsyncOperation() throws InterruptedException {
        MetricRegistry registry = SharedMetricRegistries.getOrCreate(REGISTRY_NAME);
        instance.meteredMethod().join();

        final String metricName = MetricsUtil.absoluteMetricName(SimpleAsyncTimed.class, "meteredMethod");
        final long[] values = registry.getTimers().get(metricName + ".asyncTimer").getSnapshot().getValues();
        assertEquals(1, values.length);
        assertTrue(values[0] >= TimeUnit.SECONDS.toNanos(4));
    }

    @Test
    public void correctlyAccountAsyncException() throws InterruptedException {
        MetricRegistry registry = SharedMetricRegistries.getOrCreate(REGISTRY_NAME);
        try {
            instance.exceptionMethod().join();
        } catch (Exception ignored) {
        }

        final String metricName = MetricsUtil.absoluteMetricName(SimpleAsyncTimed.class, "exceptionMethod");
        final long count = registry.getMeters().get(metricName + ".asyncExceptions").getCount();
        assertEquals(1, count);
    }
}
