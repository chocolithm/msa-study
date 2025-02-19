package com.optimagrowth.license.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.springframework.hateoas.RepresentationModel;

@Getter
@Setter
@ToString
@Entity
@Table(name = "licenses")
public class License extends RepresentationModel<License> {

  @Id
  @Column(name = "license_id", nullable = false)
  private String licenseId;
  private String description;
  @Column(name = "oranization_id", nullable = false)
  private String organizationId;
  @Column(name = "produce_name", nullable = false)
  private String productName;
  @Column(name = "license_type", nullable = false)
  private String licenseType;
  @Column(name = "comment", nullable = false)
  private String comment;

  public License withComment(String comment) {
    this.setComment(comment);
    return this;
  }
}
