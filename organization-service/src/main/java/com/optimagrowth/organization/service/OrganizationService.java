package com.optimagrowth.organization.service;

import com.optimagrowth.organization.events.source.SimpleSourceBean;
import com.optimagrowth.organization.utils.ActionEnum;
import java.util.Optional;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.optimagrowth.organization.model.Organization;
import com.optimagrowth.organization.repository.OrganizationRepository;

@Service
public class OrganizationService {
	
	private static final Logger logger = LoggerFactory.getLogger(OrganizationService.class);
	
    @Autowired
    private OrganizationRepository repository;

    @Autowired
    SimpleSourceBean simpleSourceBean;

    public Organization create(Organization organization){
      organization.setId(UUID.randomUUID().toString());
      organization = repository.save(organization);
      simpleSourceBean.publishOrganizationChange(
          ActionEnum.CREATED,
          organization.getId());
      return organization;

    }

    public Organization findById(String organizationId) {
    	Optional<Organization> opt = repository.findById(organizationId);
        return (opt.isPresent()) ? opt.get() : null;
    }

    public void update(Organization organization){
    	repository.save(organization);
    }

    public void delete(String organizationId){
    	repository.deleteById(organizationId);
    }
    
    @SuppressWarnings("unused")
	private void sleep(){
		try {
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			logger.error(e.getMessage());
		}
	}
}