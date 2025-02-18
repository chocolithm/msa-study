package com.optimagrowth.license.controller;

import com.optimagrowth.license.model.License;
import com.optimagrowth.license.service.LicenseService;
import java.util.Locale;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "v1/organization/{organizationId}/license")
public class LicenseController {

  @Autowired
  private LicenseService licenseService;

  @RequestMapping(value = "/{licenseId}", method = RequestMethod.GET)
  public ResponseEntity<License> getLicense(
      @PathVariable("organizationId") String organizationId,
      @PathVariable("licenseId") String licenseId) {
    License license = licenseService.getLicense(licenseId, organizationId);
    return ResponseEntity.ok(license);
  }

  @PutMapping
  public ResponseEntity<String> updateLicense(
      @PathVariable("organizationId") String organizationId,
      @RequestBody License request) {
    return ResponseEntity.ok(licenseService.updateLicense(request, organizationId));
  }

  @PostMapping
  public ResponseEntity<String> createLicense(
      @PathVariable("organizationId") String organizationId,
      @RequestBody License request,
      @RequestHeader(value="Accept-Language", required = false) Locale locale) {
    return ResponseEntity.ok(licenseService.createLicense(request, organizationId, locale));
  }

  @DeleteMapping
  public ResponseEntity<String> deleteLicense(
      @PathVariable("organizationId") String organizationId,
      @PathVariable("licenseId") String licenseId) {
    return ResponseEntity.ok(licenseService.deleteLicense(licenseId, organizationId));
  }
}
