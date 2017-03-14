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
    public void callTimedStaticMethodsOnce() throws InterruptedException {
        MetricRegistry registry = SharedMetricRegistries.getOrCreate(REGISTRY_NAME);
        instance.meteredMethod().join();

        final String metricName = MetricsUtil.absoluteMetricName(SimpleAsyncTimed.class, "meteredMethod");
        final long[] values = registry.getTimers().get(metricName + ".asyncTimer").getSnapshot().getValues();
        assertEquals(1, values.length);
        assertTrue(values[0] >= TimeUnit.SECONDS.toNanos(4));
    }
}
