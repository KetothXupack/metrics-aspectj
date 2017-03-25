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

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author <a href="mailto:ketoth.xupack@gmail.com">Ketoth Xupack</a>
 * @since 2017-03-25 05:09
 */
public final class SharedDefaultNameResolvers {
    private static final Map<String, DefaultNameResolver> RESOLVERS = new ConcurrentHashMap<>();

    private SharedDefaultNameResolvers() {
    }

    public static void register(final String name, final DefaultNameResolver resolver) {
        RESOLVERS.put(name, resolver);
    }

    public static DefaultNameResolver get(final String name) {
        return RESOLVERS.getOrDefault(name, DefaultNameResolver.DEFAULT);
    }
}
