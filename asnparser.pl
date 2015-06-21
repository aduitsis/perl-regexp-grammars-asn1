#!/usr/bin/env perl

use v5.20;
use strict;
use warnings;
use Regexp::Grammars;
use Regexp::Common qw (RE_num_int);
use Data::Dumper;
use YAML;

my $parser = qr/ 

	<nocontext:>
	<Start>
#########################	
	<token: ws>
		(?: \s+ | --[^\n]* )*

	<token: DOT>
		(\.)
	<token: DOUBLE_DOT>
		(\.\.)
	<token: TRIPLE_DOT>
		(\.\.\.)
	<token: COMMA>
		(,)
	<token: SEMICOLON>
		(;)
	<token: LEFT_PAREN>
		(\()
	<token: RIGHT_PAREN>
		(\))
	<token: LEFT_BRACE>
		(\{)
	<token: RIGHT_BRACE>
		(\})
	<token: LEFT_BRACKET>
		(\[)
	<token: RIGHT_BRACKET>
		(\])
	<token: MINUS>
		(-)
	<token: LESS_THAN>
		(\<)
	<token: VERTICAL_BAR>
		(\|)
	<token: DEFINITION>
		(::=)
	<token: DEFINITIONS>
		(DEFINITIONS)
	<token: EXPLICIT>                     
		(EXPLICIT)
	<token: IMPLICIT>                     
		(IMPLICIT)
	<token: TAGS>                         
		(TAGS)
	<token: BEGIN>                        
		(BEGIN)
	<token: END>                          
		(END)
	<token: EXPORTS>                      
		(EXPORTS)
	<token: IMPORTS>                      
		(IMPORTS)
	<token: FROM>                         
		(FROM)
	<token: MACRO>                        
		(MACRO)
	<token: INTEGER>                      
		(INTEGER)
	<token: REAL>                         
		(REAL)
	<token: BOOLEAN>                      
		(BOOLEAN)
	<token: NULL>                         
		(NULL)
	<token: BIT>                          
		(BIT)
	<token: OCTET>                        
		(OCTET)
	<token: STRING>                       
		(STRING)
	<token: ENUMERATED>                   
		(ENUMERATED)
	<token: SEQUENCE>                     
		(SEQUENCE)
	<token: SET>                          
		(SET)
	<token: OF>                           
		(OF)
	<token: CHOICE>                       
		(CHOICE)
	<token: UNIVERSAL>                    
		(UNIVERSAL)
	<token: APPLICATION>                  
		(APPLICATION)
	<token: PRIVATE>                      
		(PRIVATE)
	<token: ANY>                          
		(ANY)
	<token: DEFINED>                      
		(DEFINED)
	<token: BY>                           
		(BY)
	<token: OBJECT>                       
		(OBJECT)
	<token: IDENTIFIER>                   
		(IDENTIFIER)
	<token: INCLUDES>                     
		(INCLUDES)
	<token: MIN>                          
		(MIN)
	<token: MAX>                          
		(MAX)
	<token: SIZE>                         
		(SIZE)
	<token: WITH>                         
		(WITH)
	<token: COMPONENT>                    
		(COMPONENT)
	<token: COMPONENTS>                   
		(COMPONENTS)
	<token: PRESENT>                      
		(PRESENT)
	<token: ABSENT>                       
		(ABSENT)
	<token: OPTIONAL>                     
		(OPTIONAL)
	<token: DEFAULT>                      
		(DEFAULT)
	<token: TRUE>                         
		(TRUE)
	<token: FALSE>                        
		(FALSE)
	<token: PLUS_INFINITY>                
		(PLUS-INFINITY)
	<token: MINUS_INFINITY>               
		(MINUS-INFINITY)
	<token: MODULE_IDENTITY>              
		(MODULE-IDENTITY)
	<token: OBJECT_IDENTITY>              
		(OBJECT-IDENTITY)
	<token: OBJECT_TYPE>                  
		(OBJECT-TYPE)
	<token: NOTIFICATION_TYPE>            
		(NOTIFICATION-TYPE)
	<token: TRAP_TYPE>                    
		(TRAP-TYPE)
	<token: TEXTUAL_CONVENTION>           
		(TEXTUAL-CONVENTION)
	<token: OBJECT_GROUP>                 
		(OBJECT-GROUP)
	<token: NOTIFICATION_GROUP>           
		(NOTIFICATION-GROUP)
	<token: MODULE_COMPLIANCE>            
		(MODULE-COMPLIANCE)
	<token: AGENT_CAPABILITIES>           
		(AGENT-CAPABILITIES)
	<token: LAST_UPDATED>                 
		(LAST-UPDATED)
	<token: ORGANIZATION>                 
		(ORGANIZATION)
	<token: CONTACT_INFO>                 
		(CONTACT-INFO)
	<token: DESCRIPTION>                  
		(DESCRIPTION)
	<token: REVISION>                     
		(REVISION)
	<token: STATUS>                       
		(STATUS)
	<token: REFERENCE>                    
		(REFERENCE)
	<token: SYNTAX>                       
		(SYNTAX)
	<token: BITS>                         
		(BITS)
	<token: UNITS>                        
		(UNITS)
	<token: ACCESS>                       
		(ACCESS)
	<token: MAX_ACCESS>                   
		(MAX-ACCESS)
	<token: MIN_ACCESS>                   
		(MIN-ACCESS)
	<token: INDEX>                        
		(INDEX)
	<token: AUGMENTS>                     
		(AUGMENTS)
	<token: IMPLIED>                      
		(IMPLIED)
	<token: DEFVAL>                       
		(DEFVAL)
	<token: OBJECTS>                      
		(OBJECTS)
	<token: ENTERPRISE>                   
		(ENTERPRISE)
	<token: VARIABLES>                    
		(VARIABLES)
	<token: DISPLAY_HINT>                 
		(DISPLAY-HINT)
	<token: NOTIFICATIONS>                
		(NOTIFICATIONS)
	<token: MODULE>                       
		(MODULE)
	<token: MANDATORY_GROUPS>             
		(MANDATORY-GROUPS)
	<token: GROUP>                        
		(GROUP)
	<token: WRITE_SYNTAX>                 
		(WRITE-SYNTAX)
	<token: PRODUCT_RELEASE>              
		(PRODUCT-RELEASE)
	<token: SUPPORTS>                     
		(SUPPORTS)
	<token: VARIATION>                    
		(VARIATION)
	<token: CREATION_REQUIRES>            
		(CREATION-REQUIRES)

	<token: BINARY_STRING>
		([0-1]*(?:B|b))
	<token: HEXADECIMAL_STRING>
		([0-9A-Fa-f]*(?:H|h))
	<token: QUOTED_STRING>
		("([^"]|"")*+")
	<token: IDENTIFIER_STRING>
		([a-zA-Z][a-zA-Z0-9-_]*)
	<token: NUMBER_STRING>
		([0-9]+)
	<token: COMMENT>
		(--[^\n\r]*)



########################

	<rule: Start> 
		<[ModuleDefinition]>+

	<rule: ModuleDefinition>
		<ModuleIdentifier> <.DEFINITIONS> <TagDefault>? <.DEFINITION> <.BEGIN> <ModuleBody>? <.END>

	<rule: ModuleIdentifier>
		<IDENTIFIER_STRING> <ObjectIdentifierValue>?

	<rule: ModuleReference>
		<IDENTIFIER_STRING> <DOT>

	<rule: TagDefault>
		<EXPLICIT> <TAGS > | <IMPLICIT> <TAGS>

	<rule: ModuleBody>
		<ExportList>? <ImportList>? <AssignmentList>

	<rule: ExportList>
		<EXPORTS> <SymbolList>? <.SEMICOLON>

	<rule: ImportList>
		<.IMPORTS> <[SymbolsFromModule]>* <.SEMICOLON>
		(?{ 	
			# my $result = map { { $_->{ModuleIdentifier}->{IDENTIFIER_STRING} } @{ $MATCH{SymbolsFromModule} } 
		})

	<rule: SymbolsFromModule>
		<SymbolList> <.FROM> <ModuleIdentifier>

	<rule: SymbolList>
		<[Symbol]> (<.COMMA> <[Symbol]>)* 

	<rule: Symbol>
		<IDENTIFIER_STRING> | <DefinedMacroName> 

	<rule: AssignmentList>
		<[Assignment]>+ 

	<rule: Assignment>
		<MacroDefinition> <SEMICOLON>? | <TypeAssignment> <SEMICOLON>? | <ValueAssignment> <SEMICOLON>? 

	<rule: MacroDefinition>
		<MacroReference> <MACRO> <.DEFINITION> <MacroBody>

	<rule: MacroReference>
		<IDENTIFIER_STRING> | <DefinedMacroName>

	<rule: MacroBody>
		<BEGIN> <[MacroBodyElement]>* <END> | <ModuleReference> <MacroReference>

	<rule: MacroBodyElement>
		<LEFT_PAREN> | <RIGHT_PAREN> | <VERTICAL_BAR> | <DEFINITION> | <INTEGER> | <REAL> | <BOOLEAN> | <NULL> | <BIT> | <OCTET> | <STRING> | <OBJECT> | <IDENTIFIER> | <IDENTIFIER_STRING> | <QUOTED_STRING>

	<rule: TypeAssignment>
		 <IDENTIFIER_STRING> <.DEFINITION> <Type>

	<rule: Type>
		<BuiltinType> | <DefinedType> | <DefinedMacroType>

	<rule: DefinedType>
		<ModuleReference>? <IDENTIFIER_STRING> <ValueOrConstraintList>?

	<rule: BuiltinType>
		<NullType> | <BooleanType> | <RealType> | <IntegerType > | <ObjectIdentifierType> | <StringType > | <BitStringType > | <BitsType> | <SequenceType> | <SequenceOfType> | <SetType> | <SetOfType> | <ChoiceType> | <EnumeratedType> | <SelectionType> | <TaggedType> | <AnyType>

	<rule: NullType>
		<.NULL>
		(?{ $MATCH = 1 })

	<rule: BooleanType>
		<.BOOLEAN>
		(?{ $MATCH = 1 })

	<rule: RealType>
		<.REAL>
		(?{ $MATCH = 1 })

	<rule: IntegerType>
		<.INTEGER> <ValueOrConstraintList>?
		(?{ $MATCH = defined($MATCH{ ValueOrConstraintList })? $MATCH{ ValueOrConstraintList } : 1 })

	<rule: ObjectIdentifierType>
		<.OBJECT> <.IDENTIFIER>
		(?{ $MATCH = 1 })

	<rule: StringType>
		<.OCTET> <.STRING> <ConstraintList>?
		(?{ $MATCH = defined($MATCH{ ConstraintList })? $MATCH{ ConstraintList } : 1 })

	<rule: BitStringType>
		<.BIT> <.STRING> <ValueOrConstraintList>?
		(?{ $MATCH = defined($MATCH{ ValueOrConstraintList })? $MATCH{ ValueOrConstraintList } : 1 })

	<rule: BitsType>
		<.BITS> <ValueOrConstraintList>?
		(?{ $MATCH = defined($MATCH{ ValueOrConstraintList })? $MATCH{ ValueOrConstraintList } : 1 })

	<rule: SequenceType>
		<SEQUENCE> <LEFT_BRACE> <ElementTypeList>? <RIGHT_BRACE>

	<rule: SequenceOfType>
		<.SEQUENCE> <ConstraintList>? <.OF> <Type>

	<rule: SetType>
		<SET> <LEFT_BRACE> <ElementTypeList>? <RIGHT_BRACE>

	<rule: SetOfType>
		<SET> <SizeConstraint>? <OF> <Type>

	<rule: ChoiceType>
		<CHOICE> <LEFT_BRACE> <ElementTypeList> <RIGHT_BRACE>

	<rule: EnumeratedType>
		<ENUMERATED> <NamedNumberList>

	<rule: SelectionType>
		<IDENTIFIER_STRING> <LESS_THAN> <Type>

	<rule: TaggedType>
		<Tag> <ExplicitOrImplicitTag>? <Type>

	<rule: Tag>
		<LEFT_BRACKET> <Class>? <NUMBER_STRING> <RIGHT_BRACKET>

	<rule: Class>
		<UNIVERSAL> | <APPLICATION> | <PRIVATE>

	<rule: ExplicitOrImplicitTag>
		<EXPLICIT> | <IMPLICIT>

	<rule: AnyType>
		<ANY> | <ANY> <DEFINED> <BY> <IDENTIFIER_STRING>

	<rule: ElementTypeList>
		<[ElementType]> (?: <.COMMA> <[ElementType]>)*

	<rule: ElementType>
		<IDENTIFIER_STRING>? <Type> <OptionalOrDefaultElement>? | <IDENTIFIER_STRING> <COMPONENTS> <OF> <Type>

	<rule: OptionalOrDefaultElement>
		<OPTIONAL> | <DEFAULT> <IDENTIFIER_STRING>? <Value>

	<rule: ValueOrConstraintList>
		<NamedNumberList> | <ConstraintList>

	<rule: NamedNumberList>
		<.LEFT_BRACE> <[NamedNumber]> (?: <.COMMA> <[NamedNumber]>)* <.RIGHT_BRACE>

	<rule: NamedNumber>
		<IDENTIFIER_STRING> <.LEFT_PAREN> <Number> <.RIGHT_PAREN>

	<rule: Number>
		<MINUS>? <NUMBER_STRING> | <DefinedValue>

	<rule: ConstraintList>
		<.LEFT_PAREN> <[Constraint]> (?: <.VERTICAL_BAR> <[Constraint]>] )* <.RIGHT_PAREN>

	<rule: Constraint>
		<ValueConstraint> | <SizeConstraint> | <AlphabetConstraint> | <ContainedTypeConstraint> | <InnerTypeConstraint>

	<rule: ValueConstraintList>
		 <.LEFT_PAREN> <[ValueConstraint]> (?:<.VERTICAL_BAR> <[ValueConstraint]>)* <.RIGHT_PAREN>

	<rule: ValueConstraint>
		<LowerEndPoint> <ValueRange>?

	<rule: ValueRange>
		<LESS_THAN>? <DOUBLE_DOT> <LESS_THAN>? <UpperEndPoint>

	<rule: LowerEndPoint>
		<Value> | <MIN>

	<rule: UpperEndPoint>
		<Value> | <MAX>

	<rule: SizeConstraint>
		<SIZE> <ValueConstraintList>

	<rule: AlphabetConstraint>
		<FROM> <ValueConstraintList>

	<rule: ContainedTypeConstraint>
		<INCLUDES> <Type>

	<rule: InnerTypeConstraint>
		<WITH> <COMPONENT> <ValueOrConstraintList> | <WITH> <COMPONENTS> <ComponentsList>

	<rule: ComponentsList>
		<.LEFT_BRACE> <ComponentConstraint> <[ComponentsListTail]>* <.RIGHT_BRACE> | <.LEFT_BRACE> <TRIPLE_DOT> <[ComponentsListTail]>+ <.RIGHT_BRACE>

	<rule: ComponentsListTail>
		<.COMMA> <ComponentConstraint>?

	<rule: ComponentConstraint>
		<IDENTIFIER_STRING> <ComponentValuePresence>? | <ComponentValuePresence>

	<rule: ComponentValuePresence>
		<ValueOrConstraintList> <ComponentPresence>? | <ComponentPresence>

	<rule: ComponentPresence>
		<PRESENT> | <ABSENT> | <OPTIONAL>



	<rule: ValueAssignment>
		<IDENTIFIER_STRING> <Type> <.DEFINITION> <Value>

	<rule: Value>
		<BuiltinValue> | <DefinedValue>

	<rule: DefinedValue>
		<ModuleReference>? <IDENTIFIER_STRING>

	<rule: BuiltinValue>
		<NULL>	| <BooleanValue> | <SpecialRealValue> | <NumberValue> | <BinaryValue> | <HexadecimalValue> | <StringValue> | <BitOrObjectIdentifierValue>

	<rule: BooleanValue>
		<TRUE> | <FALSE>

	<rule: SpecialRealValue> 
		<PLUS_INFINITY> | <MINUS_INFINITY>

	<rule: NumberValue>
		<MINUS>? <NUMBER_STRING>

	<rule: BinaryValue>
		<BINARY_STRING>

	<rule: HexadecimalValue>
		<HEXADECIMAL_STRING>

	<rule: StringValue>
		<QUOTED_STRING>

	<rule: BitOrObjectIdentifierValue>
		<NameValueList>

	<rule: BitValue>
		<NameValueList>

	<rule: ObjectIdentifierValue>
		<NameValueList>

	<rule: NameValueList>
		<.LEFT_BRACE> <[NameValueComponent]>* <.RIGHT_BRACE>

	<rule: NameValueComponent>
		<.COMMA>? <NameOrNumber>

	<rule: NameOrNumber>
		<NUMBER_STRING> | <IDENTIFIER_STRING> | <NameAndNumber>

	<rule: NameAndNumber>
		<IDENTIFIER_STRING> <.LEFT_PAREN> <NUMBER_STRING> <.RIGHT_PAREN> | <IDENTIFIER_STRING> <.LEFT_PAREN> <DefinedValue> <.RIGHT_PAREN>


	<rule: DefinedMacroType>
		<SnmpModuleIdentityMacroType> | <SnmpObjectIdentityMacroType> | <SnmpObjectTypeMacroType> | <SnmpNotificationTypeMacroType> | <SnmpTrapTypeMacroType> | <SnmpTextualConventionMacroType> | <SnmpObjectGroupMacroType> | <SnmpNotificationGroupMacroType> | <SnmpModuleComplianceMacroType> | <SnmpAgentCapabilitiesMacroType>

	<rule: DefinedMacroName>
		<MODULE_IDENTITY> | <OBJECT_IDENTITY> | <OBJECT_TYPE> | <NOTIFICATION_TYPE> | <TRAP_TYPE> | <TEXTUAL_CONVENTION> | <OBJECT_GROUP> | <NOTIFICATION_GROUP> | <MODULE_COMPLIANCE> | <AGENT_CAPABILITIES>

	<rule: SnmpModuleIdentityMacroType>
		<MODULE_IDENTITY> <SnmpUpdatePart> <SnmpOrganizationPart> <SnmpContactPart> <SnmpDescrPart> <[SnmpRevisionPart]>*

	<rule: SnmpObjectIdentityMacroType>
		<OBJECT_IDENTITY> <SnmpStatusPart> <SnmpDescrPart> <SnmpReferPart>?  

	<rule: SnmpObjectTypeMacroType>
		<.OBJECT_TYPE> <SnmpSyntaxPart> <SnmpUnitsPart>?  <SnmpAccessPart> <SnmpStatusPart> <SnmpDescrPart>?  <SnmpReferPart>?  <SnmpIndexPart>?  <SnmpDefValPart>?

	<rule: SnmpNotificationTypeMacroType>
		<.NOTIFICATION_TYPE> <SnmpObjectsPart>?  <SnmpStatusPart> <SnmpDescrPart> <SnmpReferPart>?

	<rule: SnmpTrapTypeMacroType>
		<.TRAP_TYPE> <SnmpEnterprisePart> <SnmpVarPart>?  <SnmpDescrPart>?  <SnmpReferPart>?

	<rule: SnmpTextualConventionMacroType>
		<.TEXTUAL_CONVENTION> <SnmpDisplayPart>?  <SnmpStatusPart> <SnmpDescrPart> <SnmpReferPart>?  <SnmpSyntaxPart>

	<rule: SnmpObjectGroupMacroType>
		<.OBJECT_GROUP> <SnmpObjectsPart> <SnmpStatusPart> <SnmpDescrPart> <SnmpReferPart>?

	<rule: SnmpNotificationGroupMacroType>
		<.NOTIFICATION_GROUP> <SnmpNotificationsPart> <SnmpStatusPart> <SnmpDescrPart> <SnmpReferPart>?

	<rule: SnmpModuleComplianceMacroType>
		<.MODULE_COMPLIANCE> <SnmpStatusPart> <SnmpDescrPart> <SnmpReferPart>?  <[SnmpModulePart]>+

	<rule: SnmpAgentCapabilitiesMacroType>
		<.AGENT_CAPABILITIES> <SnmpProductReleasePart> <SnmpStatusPart> <SnmpDescrPart> <SnmpReferPart>?  <[SnmpModuleSupportPart]>*

	<rule: SnmpUpdatePart>
		<.LAST_UPDATED> <QUOTED_STRING>
		(?{ $MATCH = $MATCH{ QUOTED_STRING } })

	<rule: SnmpOrganizationPart>
		<.ORGANIZATION> <QUOTED_STRING>
		(?{ $MATCH = $MATCH{ QUOTED_STRING } })

	<rule: SnmpContactPart>
		<.CONTACT_INFO> <QUOTED_STRING>
		(?{ $MATCH = $MATCH{ QUOTED_STRING } })

	<rule: SnmpDescrPart>
		<.DESCRIPTION> <QUOTED_STRING>
		(?{ $MATCH = $MATCH{ QUOTED_STRING } })

	<rule: SnmpRevisionPart>
		<.REVISION> <Value> <.DESCRIPTION> <QUOTED_STRING>

	<rule: SnmpStatusPart>
		<.STATUS> <IDENTIFIER_STRING>
		(?{ $MATCH = $MATCH{ IDENTIFIER_STRING } })

	<rule: SnmpReferPart>
		<.REFERENCE> <QUOTED_STRING>
		(?{ $MATCH = $MATCH{ QUOTED_STRING } })

	<rule: SnmpSyntaxPart>
		<.SYNTAX> <Type>

	<rule: SnmpUnitsPart>
		<.UNITS> <QUOTED_STRING>

	<rule: SnmpAccessPart>
		<ACCESS> <IDENTIFIER_STRING> | <MAX_ACCESS> <IDENTIFIER_STRING> | <MIN_ACCESS> <IDENTIFIER_STRING>

	<rule: SnmpIndexPart>
		<INDEX> <LEFT_BRACE> <IndexValueList> <RIGHT_BRACE> | <AUGMENTS> <LEFT_BRACE> <Value> <RIGHT_BRACE>

	<rule: IndexValueList>
		<[IndexValue]> (?:<COMMA> <[IndexValue]>)*

	<rule: IndexValue>
		<Value> | <IMPLIED> <Value> | <IndexType>

	<rule: IndexType>
		<IntegerType> | <StringType> | <ObjectIdentifierType>

	<rule: SnmpDefValPart>
		<DEFVAL> <LEFT_BRACE> <Value> <RIGHT_BRACE>

	<rule: SnmpObjectsPart>
		<OBJECTS> <LEFT_BRACE> <ValueList> <RIGHT_BRACE>

	<rule: ValueList>
		<[Value]> (?:<COMMA> <[Value]>)*

	<rule: SnmpEnterprisePart>
		<ENTERPRISE> <Value>

	<rule: SnmpVarPart>
		<VARIABLES> <LEFT_BRACE> <ValueList> <RIGHT_BRACE>

	<rule: SnmpDisplayPart>
		<DISPLAY_HINT> <QUOTED_STRING>

	<rule: SnmpNotificationsPart>
		<NOTIFICATIONS> <LEFT_BRACE> <ValueList> <RIGHT_BRACE>

	<rule: SnmpModulePart>
		<MODULE> <SnmpModuleImport>?  <SnmpMandatoryPart>?  <[SnmpCompliancePart]>*

	<rule: SnmpModuleImport>
		<ModuleIdentifier>

	<rule: SnmpMandatoryPart>
		<MANDATORY_GROUPS> <LEFT_BRACE> <ValueList> <RIGHT_BRACE>

	<rule: SnmpCompliancePart>
		<ComplianceGroup> | <ComplianceObject>

	<rule: ComplianceGroup>
		<GROUP> <Value> <SnmpDescrPart>

	<rule: ComplianceObject>
		<OBJECT> Value> <SnmpSyntaxPart>?  <SnmpWriteSyntaxPart>?  <SnmpAccessPart>?  <SnmpDescrPart>?

	<rule: SnmpWriteSyntaxPart>
		<WRITE_SYNTAX> <Type>

	<rule: SnmpProductReleasePart>
		<PRODUCT_RELEASE> <QUOTED_STRING>

	<rule: SnmpModuleSupportPart>
		<SUPPORTS> <SnmpModuleImport> <INCLUDES> <LEFT_BRACE> <ValueList> <RIGHT_BRACE> <[SnmpVariationPart]>*

	<rule: SnmpVariationPart>
		<VARIATION> <Value> <SnmpSyntaxPart>?  <SnmpWriteSyntaxPart>?  <SnmpAccessPart>?  <SnmpCreationPart>?  <SnmpDefValPart>?  <SnmpDescrPart>

	<rule: SnmpCreationPart>
		<CREATION_REQUIRES> <LEFT_BRACE> <ValueList> <RIGHT_BRACE>

/x; #not strictly needed, inserted automatically by R::G

my $slurp = do { local $/ ; <> };
$slurp =~ $parser;
#print Dumper( %/ );
say Dump( \%/ );
