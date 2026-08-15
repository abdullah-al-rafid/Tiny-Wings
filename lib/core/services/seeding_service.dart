import '../../features/organizations/data/organization_repository.dart';
import '../../features/profile/data/user_repository.dart';
import '../../features/needs/data/need_repository.dart';
import '../models/organization_model.dart';
import '../models/user_model.dart';
import '../models/need_model.dart';
import '../../features/volunteering/data/volunteer_repository.dart';
import '../models/opportunity_model.dart';

class SeedingService {
  final OrganizationRepository _orgRepo;
  final UserRepository _userRepo;
  final NeedRepository _needRepo;
  final VolunteerRepository _volunteerRepo;

  SeedingService(this._orgRepo, this._userRepo, this._needRepo, this._volunteerRepo);

  Future<void> seedAll() async {
    await seedOrganizations();
    await seedNeeds();
    await seedOpportunities();
  }

  Future<void> seedOrganizations() async {
    final orgs = [
      Organization(
        id: 'anjuman-mofidul-islam',
        name: 'Anjuman Mofidul Islam',
        location: 'Dhaka',
        description: 'Providing social welfare services to the distressed since 1947.',
        about: 'Anjuman Mofidul Islam is a non-political, non-profit charitable organization in Bangladesh.',
        phone: '01711111111',
        email: 'info@anjuman.org',
        totalChildren: 450,
        status: VerificationStatus.verified,
        isFeatured: true,
        imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=1000',
      ),
      Organization(
        id: 'sos-childrens-village',
        name: 'SOS Children\'s Village',
        location: 'Sylhet',
        description: 'Building families for children in need and helping them shape their own futures.',
        about: 'SOS Children\'s Village Sylhet provides long-term care for children who have lost parental care.',
        phone: '01722222222',
        email: 'contact@sos-bangladesh.org',
        totalChildren: 120,
        status: VerificationStatus.verified,
        isFeatured: true,
        imageUrl: 'https://images.unsplash.com/photo-1540608273917-99abc2d4bd28?q=80&w=1000',
      ),
      Organization(
        id: 'chittagong-orphanage',
        name: 'Chittagong Children\'s Home',
        location: 'Chittagong',
        description: 'A safe haven for orphaned children in the port city.',
        about: 'Established in 1990, we provide education and shelter to 200+ kids.',
        phone: '01733333333',
        email: 'admin@ctg-home.org',
        totalChildren: 210,
        status: VerificationStatus.verified,
        isFeatured: false,
        imageUrl: 'https://images.unsplash.com/photo-1509099836639-18ba1795216d?q=80&w=1000',
      ),
    ];

    for (var org in orgs) {
      await _orgRepo.saveOrganization(org);
    }
  }

  Future<void> seedNeeds() async {
    final needs = [
      Need(
        id: 'food-anjuman-1',
        organizationId: 'anjuman-mofidul-islam',
        organizationName: 'Anjuman Mofidul Islam',
        title: 'Monthly Rice Supply',
        category: 'Food',
        priority: 'High',
        subtitle: 'Food support for kids',
        quantityOrAmount: 'Monthly requirements of rice for 400 children.',
        targetQuantity: 500.0,
        fulfilledQuantity: 120.0,
        unit: 'kg',
        status: 'approved',
      ),
      Need(
        id: 'books-sos-1',
        organizationId: 'sos-childrens-village',
        organizationName: 'SOS Children\'s Village',
        title: 'Primary School Textbooks',
        category: 'Education',
        priority: 'Medium',
        subtitle: 'School supplies',
        quantityOrAmount: 'New curriculum books for Grade 1-5 students.',
        targetQuantity: 200.0,
        fulfilledQuantity: 45.0,
        unit: 'sets',
        status: 'approved',
      ),
    ];

    for (var need in needs) {
      await _needRepo.saveNeed(need);
    }
  }

  Future<void> seedOpportunities() async {
    final opps = [
      Opportunity(
        id: 'scholarship-1',
        title: 'Freedom Fighters Scholarship',
        category: OpportunityCategory.scholarships,
        description: 'Full tuition for higher secondary education.',
        eligibility: 'GPA 5.0 in SSC, Orphan status',
        location: 'Bangladesh',
        contactMethod: 'Apply at freedomtrust.com',
        postedBy: 'system',
        status: OpportunityStatus.approved,
        createdAt: DateTime.now(),
      ),
      Opportunity(
        id: 'job-1',
        title: 'Apprentice Baker',
        category: OpportunityCategory.jobs,
        description: 'Trainee position at Golden Harvest Bakery.',
        eligibility: 'Age 18+, Basic English, Hardworking',
        location: 'Dhaka',
        contactMethod: 'Send SMS to 01999999999',
        postedBy: 'system',
        status: OpportunityStatus.approved,
        createdAt: DateTime.now(),
      ),
    ];

    for (var opp in opps) {
      await _volunteerRepo.saveLifeOpportunity(opp);
    }
  }
}

