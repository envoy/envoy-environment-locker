require "rails_helper"
require "securerandom"

RSpec.describe Service do
  let(:rand_str) { -> { SecureRandom.hex } }
  let(:service) { Service.new(rand_str.()) }
  let(:user) { rand_str.() }

  describe "#lock" do
    it "locks the service if no one is holding the lock" do
      expect(service).not_to be_locked
      expect(service.lock(user: user, seconds: 30)).to be_truthy
      expect(service).to be_locked
      expect(service.users).to include(user)
      rank = REDIS.zscore(Service::LOCKED_KEY, service.name)
      expect(rank).to be_within(32).of(Time.now.utc.to_i)
    end

    describe "with someone else holding the lock" do
      let(:lock_owner) { "the-lock-owner" }

      before do
        service.lock(user: lock_owner, seconds: 30)
      end

      it "queues the user to acquire the lock later" do
        expect(service.lock(user: user, seconds: 30)).to be_falsy
        expect(service.users).to include(user)
      end

      it "does not re-queue the user if its already in the queue" do
        service.lock(user: user, seconds: 30)
        service.lock(user: user, seconds: 30)
        expect(service.users.count(user)).to eql(1)
      end

      it "queues users in order of lock request" do
        another_user = rand_str.()

        service.lock(user: user, seconds: 30)
        Timecop.freeze(Time.now + 30.seconds) do
          service.lock(user: another_user, seconds: 30)
        end

        users = service.users
        expect(users.index(user)).to be < users.index(another_user)
      end
    end
  end

  describe "#unlock" do
    let(:lock_owner) { "the-lock-owner" }

    before do
      service.lock(user: lock_owner, seconds: 30)
      expect(service).to be_locked
    end

    it "releases the lock if user is the lock holder and there is no one else in queue" do
      service.unlock(user: lock_owner)
      expect(service).not_to be_locked
    end

    it "passes the lock to the next in line if user is the lock holder" do
      service.lock(user: user, seconds: 30)
      service.unlock(user: lock_owner)

      expect(service).to be_locked
      expect(service.lock_owner).to eql(user)
    end

    it "removes a user from the queue if they are waiting for the lock" do
      service.lock(user: user, seconds: 30)
      expect(service.users).to include(user)

      service.unlock(user: user)
      expect(service.users).not_to include(user)
      expect(service).to be_locked
      expect(service.lock_owner).to eql(lock_owner)
    end
  end

  describe "#expire_lock!" do
    let(:lock_owner) { "the-lock-owner" }

    before do
      service.lock(user: lock_owner, seconds: 30)
      expect(service).to be_locked
    end

    it "releases the lock for the current holder and removes them from the queue" do
      service.expire_lock!
      expect(service).not_to be_locked
      expect(service.lock_owner).to be_nil
    end

    it "passes the lock to the next in line if there's someone waiting" do
      Timecop.freeze(Time.now + 30.seconds) do
        service.lock(user: user, seconds: 30) # add user to the queue
      end

      service.expire_lock!
      expect(service).to be_locked
      expect(service.lock_owner).to eql(user)
    end
  end

  describe "#extend_lock" do
    it "extends the lock time for the current holder" do
      Timecop.freeze do
        service.lock(user: user, seconds: 30)

        service.extend_lock(seconds: 5)
        rank = REDIS.zscore(Service::LOCKED_KEY, service.name).to_i
        expect(rank).to eql(Time.now.utc.to_i + 35)
      end
    end

    # Since `zincrby` will add elements to the set if they're not there
    # we need to keep this test to ensure that the service doesn't get
    # locked if for some reason someone extends the lock of an unlocked
    # service.
    it "does nothing when the service is not locked" do
      service.extend_lock(seconds: 5)
      expect(service).not_to be_locked
      rank = REDIS.zscore(Service::LOCKED_KEY, service.name).to_i
      expect(rank).to eql(0)
    end
  end
end
