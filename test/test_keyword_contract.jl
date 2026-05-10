@testset "Keyword contract" begin
    supported_keywords = getfield(PhyloMakie, :SUPPORTED_PLOT_KEYWORDS)
    contract_entries = getfield(PhyloMakie, :KEYWORD_SURFACE_CONTRACT)
    deferred_contracts = getfield(PhyloMakie, :DEFERRED_PLOT_KEYWORD_CONTRACTS)

    @test supported_keywords == EXPECTED_SUPPORTED_PLOT_KEYWORDS
    @test length(contract_entries) == length(supported_keywords)
    @test Tuple(entry.keyword for entry in contract_entries) == supported_keywords

    contract_by_keyword = Dict(entry.keyword => entry for entry in contract_entries)

    for entry in contract_entries
        @test !isempty(entry.default_source)
        @test entry.closure_status isa Symbol
        @test entry.deferred_contract_ids isa Tuple
    end

    @test contract_by_keyword[:useedgelength].closure_status == :closed_in_tranche_2
    @test contract_by_keyword[:useedgelength].deferred_owner === nothing

    @test contract_by_keyword[:nodelabel].closure_status ==
        :helper_validation_closed_public_surface_proof_deferred
    @test contract_by_keyword[:nodelabel].deferred_owner == 5
    @test contract_by_keyword[:nodelabel].deferred_contract_ids ==
        (:nodelabel_public_surface_proof,)

    @test contract_by_keyword[:edgelabel].closure_status ==
        :helper_validation_closed_public_surface_proof_deferred
    @test contract_by_keyword[:edgelabel].deferred_owner == 5
    @test contract_by_keyword[:edgelabel].deferred_contract_ids ==
        (:edgelabel_public_surface_proof,)

    @test contract_by_keyword[:xlim].closure_status ==
        :structural_validation_closed_helper_message_closed_public_surface_proof_deferred
    @test contract_by_keyword[:xlim].deferred_owner == 5
    @test contract_by_keyword[:xlim].deferred_contract_ids ==
        (:xlim_public_surface_proof,)

    @test contract_by_keyword[:ylim].closure_status ==
        :structural_validation_closed_helper_message_closed_public_surface_proof_deferred
    @test contract_by_keyword[:ylim].deferred_owner == 5
    @test contract_by_keyword[:ylim].deferred_contract_ids ==
        (:ylim_public_surface_proof,)

    @test [contract.id for contract in deferred_contracts] ==
        collect(EXPECTED_DEFERRED_PLOT_CONTRACT_IDS)
    @test [contract.owner_tranche for contract in deferred_contracts] == [5, 5, 5, 5]
end
