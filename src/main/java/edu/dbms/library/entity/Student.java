package edu.dbms.library.entity;

import java.util.Collection;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name="student")
@PrimaryKeyJoinColumn(name="student_id", referencedColumnName="patron_id")
public class Student extends Patron {

	@Column(name="phone_no", nullable=false)
	private String phoneNumber;
	
	@Column(name="alt_phone_no")
	private String alternatePhoneNumber;
	
	@Embedded
	private Address homeAddress;
	
	@Temporal(TemporalType.DATE)
	@Column(name="dob")
	private Date dateOfBirth;
	
	private Character sex;

	@JoinTable(name="enroll",
			joinColumns = {
				@JoinColumn(name="student_id", referencedColumnName="student_id")
			},
			inverseJoinColumns = {
					@JoinColumn(name="course_id", referencedColumnName="id")
			}
	)
	@ManyToMany
	private Collection<Course> courses;

	public Student() {}
	
	public Student(String phoneNumber, String alternatePhoneNumber, Address homeAddress, Date dateOfBirth,
			Character sex) {
		super();
		this.phoneNumber = phoneNumber;
		this.alternatePhoneNumber = alternatePhoneNumber;
		this.homeAddress = homeAddress;
		this.dateOfBirth = dateOfBirth;
		this.sex = sex;
	}

	public String getPhoneNumber() {
		return phoneNumber;
	}

	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}

	public String getAlternatePhoneNumber() {
		return alternatePhoneNumber;
	}

	public void setAlternatePhoneNumber(String alternatePhoneNumber) {
		this.alternatePhoneNumber = alternatePhoneNumber;
	}

	public Address getHomeAddress() {
		return homeAddress;
	}

	public void setHomeAddress(Address homeAddress) {
		this.homeAddress = homeAddress;
	}

	public Date getDateOfBirth() {
		return dateOfBirth;
	}

	public void setDateOfBirth(Date dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}

	public Character getSex() {
		return sex;
	}

	public void setSex(Character sex) {
		this.sex = sex;
	}
}
