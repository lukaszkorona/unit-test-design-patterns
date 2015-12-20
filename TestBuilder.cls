public with sharing class TestBuilder {

    public static final String DEFAULT_ACCOUNT_NAME = 'UT Account Name';
    public static final String DEFAULT_OPPORTUNITY_NAME = 'UT Opportunity Name';
    public static final String DEFAULT_FIRST_NAME = 'UT First Name';
    public static final String DEFAULT_LAST_NAME = 'UT Last Name';
    public static final String DEFAULT_EMAIL_SUFFIX = 'example.com.test';
    public static final String DEFAULT_USER_FEDERATION = 'federation';
    public static final String DEFAULT_TIMEZONE = 'Europe/Warsaw';
    public static final String DEFAULT_USER_TITLE = 'Unit Test User';
    public static final String DEFAULT_USER_PROFILE = 'System Administrator';
    public static final String DEFAULT_LOCALE = 'en_US';
    public static final String DEFAULT_EMAIL_ENCODING_KEY = 'ISO-8859-1';
    public static final String DEFAULT_LANGUAGE_LOCALE_KEY = 'en_US';
    public static final String DEFAULT_LOCALE_SID_KEY = 'en_US';
    public static final String CLOSED_WON = 'Closed Won';
    public static final String QUALIFIED = 'Qualified';
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String PROSPECTING_STAGE_NAME = 'Prospecting';
    
    private static User currentUser;
    
    public static User getCurrentUser() {
        if (currentUser == null) {
            currentUser = new User(Id = UserInfo.getUserId());
        }
        return currentUser;
    }
    
    public static Map<String, Id> profiles{
        get{
            if (profiles == null || profiles.isEmpty()) {
                Map<String, Id> pMap = new Map<String, Id>();
                for (Profile p : [SELECT Id, Name FROM Profile]) {
                    pMap.put(p.Name, p.Id);
                }
                return pMap;
            }
            return profiles;
        }
        set;
    }
    
    public static Id getProfileId(String name) {
        return profiles.get(name);
    }
    
    public class AccountBuilder
    {
        private Account record = new Account(Name = DEFAULT_ACCOUNT_NAME);
        
        public AccountBuilder withOwner(User user) {
            record.OwnerId = user.Id;
            return this;
        }
        
        public Account build() {
            return record.clone();
        }
        
        public Account buildAndSave() {
            Account clonedRecord = this.build();
            insert clonedRecord;
            return clonedRecord;
        }
        
        public List<Account> buildList(Integer amount) {
            List<Account> output = new List<Account>();
            for(Integer i = 0; i < amount; ++i) {
                output.add(this.build());
            }
            
            return output;
        }
        
        public List<Account> buildListAndSave(Integer amount) {
            List<Account> output = this.buildList(amount);
            insert output;
            return output;
        }
    }
    
    public class ContactBuilder
    {
        private Contact record = new Contact(
            FirstName = DEFAULT_FIRST_NAME, 
            LastName = DEFAULT_LAST_NAME + Math.abs(Crypto.getRandomInteger()),
            Email = Math.abs(Crypto.getRandomInteger()) + '@' + DEFAULT_EMAIL_SUFFIX
        );
        
        public ContactBuilder withFirstName(String firstName) {
            record.FirstName = firstName;
            return this;
        }
        
        public ContactBuilder withLastName(String lastName) {
            record.LastName = lastName;
            return this;
        }
        
        public ContactBuilder withRandomLastName() {
            record.LastName = '' + Math.abs(Crypto.getRandomInteger());
            return this;
        }
        
        public ContactBuilder withAccount(Account account) {
            record.AccountId = account.Id;
            return this;
        }
        
        public ContactBuilder withEmail(String email) {
            record.email = email;
            return this;
        }
        
        public Contact build() {
            return record.clone();
        }
        
        public Contact buildAndSave() {
            Contact clonedRecord = this.build();
            insert clonedRecord;
            return clonedRecord;
        }
        
        public List<Contact> buildList(Integer amount) {
            List<Contact> output = new List<Contact>();
            for(Integer i = 0; i < amount; ++i) {
                output.add(this.withRandomLastName().build());
            }
            
            return output;
        }
        
        public List<Contact> buildListAndSave(Integer amount) {
            List<Contact> output = this.buildList(amount);
            insert output;
            return output;
        }
    }
    
    public class OpportunityBuilder
    {
        private Opportunity record = new Opportunity(Name = DEFAULT_OPPORTUNITY_NAME,StageName=PROSPECTING_STAGE_NAME, CloseDate=Date.today());
        
        public OpportunityBuilder withAccount(Account account) {
            record.AccountId = account.Id;
            return this;
        }
        
        public OpportunityBuilder withStage(String stageName) {
            record.StageName = stageName;
            return this;
        }
        
        public OpportunityBuilder withCloseDate(Date closeDate) {
            record.CloseDate = closeDate;
            return this;
        }
        
        public Opportunity build() {
            return record.clone();
        }
        
        public Opportunity buildAndSave() {
            Opportunity clonedRecord = this.build();
            insert clonedRecord;
            return clonedRecord;
        }
        
        public List<Opportunity> buildList(Integer amount) {
            List<Opportunity> output = new List<Opportunity>();
            for(Integer i = 0; i < amount; ++i) {
                output.add(this.build());
            }
            
            return output;
        }
        
        public List<Opportunity> buildListAndSave(Integer amount) {
            List<Opportunity> output = this.buildList(amount);
            insert output;
            return output;
        }
        
        public Opportunity buildDecorated(List<TestBuilder.OpportunityDecorator> decorators) {
            Opportunity clonedRecord = this.build();
            for(OpportunityDecorator oppDecorator : decorators) {
                oppDecorator.decorate(clonedRecord);
            }
            return clonedRecord;
        }
        
        public Opportunity buildDecoratedAndSave(List<TestBuilder.OpportunityDecorator> decorators) {
            Opportunity clonedAndDecoratedRecord = this.buildDecorated(decorators);
            insert clonedAndDecoratedRecord;
            return clonedAndDecoratedRecord;
        }
        
        public List<Opportunity> buildDecoratedList(Integer amount, List<TestBuilder.OpportunityDecorator> decorators) {
            List<Opportunity> output = new List<Opportunity>();
            for (Integer i = 0; i < amount; ++i) {
                output.add(this.buildDecorated(decorators));
            }
            return output;
        }
        
        public List<Opportunity> buildDecoratedListAndSave(Integer amount, List<TestBuilder.OpportunityDecorator> decorators) {
            List<Opportunity> output = this.buildDecoratedList(amount, decorators);
            insert output;
            return output;
        }
    }
    
    public interface OpportunityDecorator{
        Opportunity decorate(Opportunity opp);
    }
        
    public class AmountDecorator implements OpportunityDecorator{
        Decimal minValue = 1000.00;
        Decimal maxValue = 100000.00;
        
        public AmountDecorator(Decimal minValue, Decimal maxValue) {
            if (minValue > maxValue) {
                maxValue = minValue;
            }
            this.minValue = minValue;
            this.maxValue = maxValue;
        }
        
        public AmountDecorator(Decimal minValue) {
            this(minValue, 10000.00);
        }
        
        public Opportunity decorate(Opportunity opportunityToDecorate) {
            opportunityToDecorate.Amount = getRandomDecimal(minValue, maxValue);
            return opportunityToDecorate;
        }
    }
    
    public class QuantityDecorator implements OpportunityDecorator{
        Integer minValue = 1;
        Integer maxValue = 10;
        
        public QuantityDecorator(Integer minValue, Integer maxValue) {
            if (minValue > maxValue) {
                maxValue = minValue;
            }
            this.minValue = minValue;
            this.maxValue = maxValue;
        }
        
        public QuantityDecorator(Integer minValue) {
            this(minValue, 10000);
        }
        
        public Opportunity decorate(Opportunity opportunityToDecorate) {
            opportunityToDecorate.TotalOpportunityQuantity = getRandomInteger(minValue, maxValue);
            return opportunityToDecorate;
        }
    }
    
            
    public class OpportunityAccountDecorator implements OpportunityDecorator{
        public Opportunity decorate(Opportunity opportunityToDecorate) {
            opportunityToDecorate.Account = new TestBuilder.AccountBuilder().build();
            return opportunityToDecorate;
        }
    }
    
    public static Decimal getRandomDecimal(Decimal lower, Decimal upper) {
        return Math.round(Math.random() * (upper - lower )) + lower;
    }
    
    public static Integer getRandomInteger(Integer lower, Integer upper) {
        return Math.round(Math.random() * (upper - lower)) + lower;
    }
    
    public class UserBuilder
    {
        private User record = new User(
            IsActive = true, 
            Title = DEFAULT_USER_TITLE, 
            Alias = ('' + Math.abs(Crypto.getRandomInteger())).right(8), 
            LastName = DEFAULT_FIRST_NAME + Math.abs(Crypto.getRandomInteger()), 
            FirstName = DEFAULT_LAST_NAME + Math.abs(Crypto.getRandomInteger()),
            UserName = Math.abs(Crypto.getRandomInteger()) + '@' + DEFAULT_EMAIL_SUFFIX,
            Email = Math.abs(Crypto.getRandomInteger()) + '@' + DEFAULT_EMAIL_SUFFIX,
            TimeZoneSidKey = DEFAULT_TIMEZONE,
            LocaleSidKey = DEFAULT_LOCALE,
            EmailEncodingKey = DEFAULT_EMAIL_ENCODING_KEY,
            LanguageLocaleKey = DEFAULT_LANGUAGE_LOCALE_KEY,
            ProfileId = getProfileId(DEFAULT_USER_PROFILE)
        );
        
        public UserBuilder withFirstName(String name) {
            record.FirstName = name;
            return this;
        }
        
        public UserBuilder withLastName(String lastName) {
            record.LastName = lastName;
            return this;
        }
        
        public UserBuilder withRandomUsername() {
            record.UserName = Math.abs(Crypto.getRandomInteger()) + '@' + DEFAULT_EMAIL_SUFFIX;
            return this;
        }
        
        public UserBuilder withEmail(String email) {
            record.Email = email;
            return this;
        }
        
        public UserBuilder withIsActive(Boolean isActive) {
            record.IsActive = isActive;
            return this;
        }
        
        public UserBuilder withTitle(String title) {
            record.Title = title;
            return this;
        }
        
        public UserBuilder withAlias(String alias) {
            record.Alias = alias;
            return this;
        }
        
        public UserBuilder withProfile(Id profileId) {
            record.ProfileId = profileId;
            return this;
        }
        
        public UserBuilder withUserRole(Id userRoleId) {
            record.UserRoleId = userRoleId;
            return this;
        }
        
        public UserBuilder withLocaleSidKey(String localeSidKey) {
            record.LocaleSidKey = localeSidKey;
            return this;
        }
        
        public UserBuilder withTimeZoneSidKey(String timeZoneSidKey) {
            record.TimeZoneSidKey = timeZoneSidKey;
            return this;
        }
        
        public UserBuilder withEmailEncodingKey(String emailEncodingKey) {
            record.EmailEncodingKey = emailEncodingKey;
            return this;
        }
        
        public UserBuilder withLanguageLocaleKey(String languageLocaleKey) {
            record.LanguageLocaleKey = languageLocaleKey;
            return this; 
        }
        
        public User build() {
            return record.clone();
        }
        
        public User buildAndSave() {
            User clonedRecord = this.build();
            try {
                insert clonedRecord;
            } catch(Exception e) {
                System.debug(e.getMessage());
                User user = [SELECT Id FROM User WHERE ProfileId = :TestBuilder.getProfileId(SYSTEM_ADMINISTRATOR) AND IsActive = true LIMIT 1];
                user.IsActive = false;
                update user;
                insert clonedRecord;
            }
            
            return clonedRecord;
        }
        
        public List<User> buildList(Integer quantity) {
            List<User> output = new List<User>();
            for (Integer i = 0; i < quantity; i++) {
                output.add(this.withRandomUsername().build());
            }
            return output;
        }
        
        public List<User> buildListAndSave(Integer quantity) {
            List<User> output = buildList(quantity);
            insert output;
            return output;
        }
    }
}