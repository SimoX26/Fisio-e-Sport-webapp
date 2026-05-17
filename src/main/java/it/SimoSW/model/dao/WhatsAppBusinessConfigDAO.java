package it.SimoSW.model.dao;

import it.SimoSW.model.WhatsAppBusinessConfig;

import java.util.Optional;

public interface WhatsAppBusinessConfigDAO {

    Optional<WhatsAppBusinessConfig> findByTherapistId(long therapistId);

    WhatsAppBusinessConfig saveOrUpdate(WhatsAppBusinessConfig config);
}
