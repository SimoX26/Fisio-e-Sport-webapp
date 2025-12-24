package it.SimoSW.util;

import java.util.HashMap;
import java.util.Map;

/**
 * SessionManager
 * <p>
 * The {@code SessionManager} class provides a simple, centralized mechanism
 * for managing application-wide session-like data using a Singleton pattern.
 * It allows storing, retrieving, and removing arbitrary attributes identified
 * by a string key.
 * <p>
 * This class is typically used to share state between different layers
 * of the application (e.g., GUI controllers, application controllers)
 * without passing objects explicitly through method parameters.
 * <p>
 * Design characteristics:
 * <ul>
 *     <li>Implements the <b>Singleton</b> pattern using the
 *     <b>Initialization-on-demand holder</b> idiom</li>
 *     <li>Lazy initialization and thread-safe instance creation</li>
 *     <li>Key–value based storage for session attributes</li>
 * </ul>
 * <p>
 * <b>Note:</b> This implementation is not synchronized. If the application
 * becomes multithreaded, access to the internal map should be synchronized
 * or replaced with a concurrent data structure.
 */
public class SessionManager {

    /**
     * Internal map used to store session attributes.
     * The key uniquely identifies the attribute, while the value
     * can be any object.
     */
    private final Map<String, Object> attributi = new HashMap<>();

    /**
     * Private constructor to prevent external instantiation.
     * Ensures that only one instance of {@code SessionManager}
     * exists in the application.
     */
    private SessionManager() {}

    /**
     * Holder class for lazy-loaded Singleton instance.
     * The instance is created only when {@link #getInstance()}
     * is called for the first time.
     */
    private static class Holder {
        private static final SessionManager INSTANCE = new SessionManager();
    }

    /**
     * Returns the unique instance of {@code SessionManager}.
     *
     * @return the Singleton instance of {@code SessionManager}
     */
    public static SessionManager getInstance() {
        return Holder.INSTANCE;
    }

    /**
     * Stores or replaces a session attribute.
     * <p>
     * If an attribute with the same key already exists,
     * its value will be overwritten.
     *
     * @param key   the unique identifier of the attribute
     * @param value the value to associate with the key
     */
    public void setAttributo(String key, Object value) {
        attributi.put(key, value);
    }

    /**
     * Retrieves a session attribute by its key.
     *
     * @param key the unique identifier of the attribute
     * @return the associated value, or {@code null} if the attribute does not exist
     */
    public Object getAttributo(String key) {
        return attributi.get(key);
    }

    /**
     * Removes a session attribute.
     * <p>
     * If the key does not exist, this method has no effect.
     *
     * @param key the unique identifier of the attribute to remove
     */
    public void removeAttributo(String key) {
        attributi.remove(key);
    }
}
