package com.optimagrowth.license.service.client;

import brave.ScopedSpan;
import brave.Tracer;
import com.optimagrowth.license.model.Organization;
import com.optimagrowth.license.repository.OrganizationRedisRepository;
import com.optimagrowth.license.utils.UserContext;
import org.keycloak.adapters.springsecurity.client.KeycloakRestTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

@Component
public class OrganizationRestTemplateClient {

  @Autowired
  private KeycloakRestTemplate restTemplate;

  @Autowired
  Tracer tracer;

  @Autowired
  OrganizationRedisRepository redisRepository;

  private static final Logger logger = LoggerFactory.getLogger(
      OrganizationRestTemplateClient.class);

  private Organization checkRedisCache(String organizationId) {
    ScopedSpan newSpan = tracer.startScopedSpan("readLicensingDataFromRedis");

    try {
      return redisRepository.findById(organizationId).orElse(null);
    } catch (Exception ex) {
      logger.error(
          "Error encountered while trying to retrieve organization {} check Redis Cache. Exception {}",
          organizationId, ex);
      return null;
    } finally {
      newSpan.tag("perr.service", "redis");
      newSpan.annotate("Client received");
      newSpan.finish();
    }
  }

  private void cacheOrganizationObject(Organization organization) {
    try {
      redisRepository.save(organization);
    } catch (Exception ex) {
      logger.error("Unable to cache organization {} in Redis. Exception {}", organization.getId(),
          ex);
    }
  }

  public Organization getOrganization(String organizationId) {
    logger.debug("In Licensing Service.getOrganization: {}", UserContext.getCorrelationId());

    Organization organization = checkRedisCache(organizationId);
    if (organization != null) {
      logger.debug("I have successfully retrieved an organization {} from the redis cache: {}",
          organizationId, organization);
      return organization;
    }

    logger.debug("Unable to locate organization from the redis cache: {}", organizationId);
    ResponseEntity<Organization> restExchange = restTemplate.exchange(
        "http://gateway:8072/organization/v1/organization/{organizationId}", HttpMethod.GET,
        null, Organization.class, organizationId);

    organization = restExchange.getBody();
    if (organization != null) {
      cacheOrganizationObject(organization);
    }

    return restExchange.getBody();
  }
}